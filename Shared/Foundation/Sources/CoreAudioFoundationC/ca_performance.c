#include "ca_performance.h"
#include <stdlib.h>
#include <stdio.h>

// Global variables for time conversion
static mach_timebase_info_data_t g_timebase_info = {0, 0};
static bool g_timebase_initialized = false;

// Initialize timebase info
static void InitializeTimebase(void) {
    if (!g_timebase_initialized) {
        mach_timebase_info(&g_timebase_info);
        g_timebase_initialized = true;
    }
}

// Convert mach time to seconds
static double MachTimeToSeconds(uint64_t mach_time) {
    InitializeTimebase();
    uint64_t nanoseconds = mach_time * g_timebase_info.numer / g_timebase_info.denom;
    return (double)nanoseconds / 1e9;
}

// Timer implementation
CAPerformanceTimer* CreatePerformanceTimer(void) {
    CAPerformanceTimer* timer = malloc(sizeof(CAPerformanceTimer));
    if (timer) {
        timer->start_time = 0;
        timer->end_time = 0;
        timer->is_running = false;
    }
    return timer;
}

void FreePerformanceTimer(CAPerformanceTimer* timer) {
    if (timer) {
        free(timer);
    }
}

void StartTimer(CAPerformanceTimer* timer) {
    if (timer) {
        timer->start_time = mach_absolute_time();
        timer->is_running = true;
    }
}

void StopTimer(CAPerformanceTimer* timer) {
    if (timer && timer->is_running) {
        timer->end_time = mach_absolute_time();
        timer->is_running = false;
    }
}

double GetElapsedSeconds(CAPerformanceTimer* timer) {
    if (!timer) return 0.0;
    
    uint64_t end_time = timer->is_running ? mach_absolute_time() : timer->end_time;
    uint64_t elapsed = end_time - timer->start_time;
    return MachTimeToSeconds(elapsed);
}

double GetElapsedMilliseconds(CAPerformanceTimer* timer) {
    return GetElapsedSeconds(timer) * 1000.0;
}

double GetElapsedMicroseconds(CAPerformanceTimer* timer) {
    return GetElapsedSeconds(timer) * 1000000.0;
}

// Convenience function for measuring execution time
double MeasureExecutionTime(void (*function)(void*), void* userData) {
    if (!function) return 0.0;
    
    CAPerformanceTimer* timer = CreatePerformanceTimer();
    if (!timer) return 0.0;
    
    StartTimer(timer);
    function(userData);
    StopTimer(timer);
    
    double elapsed = GetElapsedSeconds(timer);
    FreePerformanceTimer(timer);
    
    return elapsed;
}

// Memory tracking (basic implementation)
static CAMemoryStats g_memory_stats = {0, 0, 0, 0};

void ResetMemoryStats(void) {
    g_memory_stats.current_allocations = 0;
    g_memory_stats.peak_allocations = 0;
    g_memory_stats.total_allocated = 0;
    g_memory_stats.total_freed = 0;
}

CAMemoryStats GetMemoryStats(void) {
    return g_memory_stats;
}
