#include <stdio.h>
#include "journal.h"
#include <pthread.h>
#include <semaphore.h>

// Number of threads we need for project
#define NUM_THREADS 3
int sleeper = 0;

typedef struct
{
	struct write_request *buffer[BUFFER_SIZE];
	int head;
	int tail;
	int size;
} circ_buff_t;

circ_buff_t requestBuffer, metaDataBuffer, commitCompletedBuffer;

sem_t mutex;
// sem_t requestBufferMutexLock, metaDataBufferMutexLock, commitCompletedBufferMutexLock;
sem_t requestBufferHasSpaceMutex, requestBufferNotEmptyMutex;
sem_t metaDataBufferHasSpaceMutex, metaDataBufferNotEmptyMutex;
sem_t commitCompletedBufferHasSpaceMutex, commitCompletedBufferNotEmptyMutex;

pthread_t metaDataThread, journalCommitWriteThread, checkpointThread;

// Enqueue a write request
int enqueue(circ_buff_t *currBuffer, struct write_request *wr)
{
	int nextHead = currBuffer->head + 1; // Move down the circular buffer
	if (nextHead >= BUFFER_SIZE)
	{
		nextHead = 0; // If we're trying to point head past buffer size reset to 0 index.
	}

	currBuffer->buffer[currBuffer->head] = wr; // Put WR into buffer
	currBuffer->head = nextHead;			   // Set next head
	currBuffer->size++;
	// printf("-----Finished enqueueing something-----\n");
	//  return 0;
}

// Dequeue a write request and return it
struct write_request *dequeue(circ_buff_t *currBuffer)
{
	int nextTail;
	nextTail = currBuffer->tail + 1;
	if (nextTail >= BUFFER_SIZE)
	{
		nextTail = 0;
	}
	struct write_request *wr = currBuffer->buffer[currBuffer->tail];
	currBuffer->tail = nextTail;
	currBuffer->size--;
	return wr;
	// If head == tail then the queue is empty -> Do nothing
	// if (currBuffer->head == currBuffer->tail)
	// {
	// 	return 0;
	// }
	// else
	// {
	// 	currBuffer->size--;
	// 	int nextTail = currBuffer->tail + 1;
	// 	if (nextTail >= BUFFER_SIZE)
	// 	{
	// 		nextTail = 0;
	// 	}
	// 	struct write_request *wr = currBuffer->buffer[currBuffer->tail];
	// 	currBuffer->tail = nextTail;
	// 	return wr;
	// }
}

void *metaDataWrite()
{
	while (1)
	{
		// Wait for buffer to not be empty
		sem_wait(&requestBufferNotEmptyMutex);
		// Lock since we're doing stuff
		sem_wait(&mutex);
		printf("Thread 1 processing %d %d %d\n", requestBuffer.size, metaDataBuffer.size, commitCompletedBuffer.size);

		struct write_request *wr = dequeue(&requestBuffer);
		issue_write_data(wr->data, wr->data_idx);
		issue_journal_txb();
		issue_journal_bitmap(wr->bitmap, wr->bitmap_idx);
		issue_journal_inode(wr->inode, wr->inode_idx);
		// Unlock this thread
		sem_post(&mutex);
		// sem_post(&requestBufferNotEmptyMutex);
		sem_post(&requestBufferHasSpaceMutex);
		if (metaDataBuffer.size >= 7)
		{
			printf("*Thread stuck because Meta Data buffer is full* %d, %d, %d\n", requestBuffer.size, metaDataBuffer.size, commitCompletedBuffer.size);
		}

		// Wait until next buffer has space
		sem_wait(&metaDataBufferHasSpaceMutex);
		sem_wait(&mutex);
		// enqueue into next buffer once it has space
		enqueue(&metaDataBuffer, wr);
		// Indicate the next buffer is not empty
		sem_post(&metaDataBufferNotEmptyMutex);
		sem_post(&mutex);
	}
}

int hasPrintedBlock = 0;

void *journalCommit()
{
	while (1)
	{
		// Wait for buffer to not be empty
		sem_wait(&metaDataBufferNotEmptyMutex);
		// Lock since we're doing stuff
		sem_wait(&mutex);
		printf("Thread 2 processing %d %d %d\n", requestBuffer.size, metaDataBuffer.size, commitCompletedBuffer.size);

		struct write_request *wr = dequeue(&metaDataBuffer);

		// commit transaction by writing txe
		if (hasPrintedBlock == 0)
		{
			printf("Blocking thread by sleeping for 1s\n");
			hasPrintedBlock++;
		}

		issue_journal_txe();
		// Unlock this thread
		sem_post(&mutex);
		// sem_post(&requestBufferNotEmptyMutex);
		sem_post(&metaDataBufferHasSpaceMutex);
		if (commitCompletedBuffer.size >= 7)
		{
			printf("*Thread stuck because Commit Completed buffer is full* %d, %d, %d\n", requestBuffer.size, metaDataBuffer.size, commitCompletedBuffer.size);
		}

		// Wait until next buffer has space
		sem_wait(&commitCompletedBufferHasSpaceMutex);
		sem_wait(&mutex);
		// enqueue into next buffer once it has space
		enqueue(&commitCompletedBuffer, wr);
		sem_post(&mutex);
		// Indicate the next buffer is not empty
		sem_post(&commitCompletedBufferNotEmptyMutex);
	}
}

void *journalCommitComplete()
{
	while (1)
	{
		// Wait for buffer to not be empty -- this also avoids race conditions
		sem_wait(&commitCompletedBufferNotEmptyMutex);
		// Lock since we're doing stuff
		sem_wait(&mutex);
		printf("Thread 3 processing %d %d %d\n", requestBuffer.size, metaDataBuffer.size, commitCompletedBuffer.size);

		struct write_request *wr = dequeue(&commitCompletedBuffer);

		// checkpoint by writing metadata
		issue_write_bitmap(wr->bitmap, wr->bitmap_idx);
		issue_write_inode(wr->inode, wr->inode_idx);
		sem_post(&mutex);
		sem_post(&commitCompletedBufferHasSpaceMutex);
		// tell the file system that the write is complete
		write_complete();
	}
}

/* This function can be used to initialize the buffers and threads.
 */
void init_journal()
{
	// Initialize semaphore
	sem_init(&mutex, 0, 1);

	sem_init(&requestBufferHasSpaceMutex, 0, 8);
	sem_init(&requestBufferNotEmptyMutex, 0, 0);

	sem_init(&metaDataBufferHasSpaceMutex, 0, 8);
	sem_init(&metaDataBufferNotEmptyMutex, 0, 0);

	sem_init(&commitCompletedBufferHasSpaceMutex, 0, 8);
	sem_init(&commitCompletedBufferNotEmptyMutex, 0, 0);

	// Create threads to run concurrently
	pthread_create(&metaDataThread, NULL, metaDataWrite, NULL);
	pthread_create(&journalCommitWriteThread, NULL, journalCommit, NULL);
	pthread_create(&checkpointThread, NULL, journalCommitComplete, NULL);
}

/* This function is called by the file system to request writing data to
 * persistent storage.
 *
 * This is the non-thread-safe solution to the problem. It issues all writes in
 * the correct order, but it doesn't wait for each phase to complete before
 * beginning the next. As a result the journal can become inconsistent and
 * unrecoverable.
 */
void request_write(struct write_request *wr)
{
	// Enqueue to requestBuffer
	sem_wait(&requestBufferHasSpaceMutex);
	sem_wait(&mutex);
	enqueue(&requestBuffer, wr);
	sem_post(&mutex);
	sem_post(&requestBufferNotEmptyMutex);
}

/* This function is called by the block service when writing the txb block
 * to persistent storage is complete (e.g., it is physically written to disk).
 */
void journal_txb_complete()
{
	// printf("journal txb complete\n");
}

void journal_bitmap_complete()
{
	// printf("journal bitmap complete\n");
}

void journal_inode_complete()
{
	// printf("journal inode complete\n");
}

void write_data_complete()
{
	// printf("write data complete\n");
}

void journal_txe_complete()
{
	// printf("jounrnal txe complete\n");
}

void write_bitmap_complete()
{
	// printf("write bitmap complete\n");
}

void write_inode_complete()
{
	// printf("write inode complete\n");
}
