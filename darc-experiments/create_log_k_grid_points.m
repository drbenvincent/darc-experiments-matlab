function logk_values = create_log_k_grid_points()

N_GRID_POINTS = 200;
MIN_LOG_K = -16;
MAX_LOG_K = 5;

logk_values = linspace(MIN_LOG_K, MAX_LOG_K, N_GRID_POINTS);
end