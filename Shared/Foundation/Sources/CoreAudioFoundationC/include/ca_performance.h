// ca_performance.h - Performance Measurement Utilities
#ifndef CA_PERFORMANCE_H
#define CA_PERFORMANCE_H

#include <mach/mach_time.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// High-resolution timing
typedef struct {
    uint64_t start_time;
    uint64_t end_time;
    bool is_running;
} CAPerformanceTimer;

// Timer operations
CAPerformanceTimer* CreatePerformanceTimer(void);
void FreePerformanceTimer(CAPerformanceTimer* timer);
void StartTimer(CAPerformanceTimer* timer);
void StopTimer(CAPerformanceTimer* timer);
double GetElapsedSeconds(CAPerformanceTimer* timer);
double GetElapsedMilliseconds(CAPerformanceTimer* timer);
double GetElapsedMicroseconds(CAPerformanceTimer* timer);

// Convenience functions for quick measurements
double MeasureExecutionTime(void (*function)(void*), void* userData);

// Memory tracking
typedef struct {
    size_t current_allocations;
    size_t peak_allocations;
    size_t total_allocated;
    size_t total_freed;
} CAMemoryStats;

void ResetMemoryStats(void);
CAMemoryStats GetMemoryStats(void);

#ifdef __cplusplus
}
#endif

#endif // CA_PERFORMANCE_H
