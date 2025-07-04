#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;

    if (thread_param != NULL)
    {
        struct thread_data * ctx = (struct thread_data *)thread_param;

        (void)usleep(ctx->wait_to_obtain_ms * 1000);

        (void)pthread_mutex_lock(ctx->p_mutex);

        (void)usleep(ctx->wait_to_release_ms * 1000);

        (void)pthread_mutex_unlock(ctx->p_mutex);

        ctx->thread_complete_success = true;
    }

    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */

    struct thread_data * p_thread_data = malloc(sizeof(struct thread_data));

    p_thread_data->p_mutex = mutex;
    p_thread_data->wait_to_obtain_ms = wait_to_obtain_ms;
    p_thread_data->wait_to_release_ms = wait_to_release_ms;

    pthread_t rc = pthread_create(thread, NULL, threadfunc, p_thread_data);

    if (rc == 0)
    {
        return true;
    }
    else
    {
        return false;
    }

    return false;
}

