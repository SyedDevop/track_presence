import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/models/task_model.dart';
import 'package:vcare_attendance/router/router_name.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final List<Task> _tasks = [];
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;

  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;
  String? _filterStatus = "assigned";
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadTasks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTasks();
    }

    if (_scrollController.position.pixels > 100) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  Future<void> _loadTasks({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _tasks.clear();
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final response = await Api.task.getTasks(
        showAll: _showAll,
        status: _filterStatus,
        page: _currentPage,
        limit: 20,
      );

      if (response.isSuccess && response.data != null) {
        final newTasks = response.data!;
        final pagination = response.pagination;

        setState(() {
          _tasks.addAll(newTasks);
          _hasMore = pagination?.hasNext ?? false;
          if (newTasks.isNotEmpty) _currentPage++;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Unknown error occurred';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTasks() async {
    if (!_hasMore || _isLoading) return;
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: RefreshIndicator(
        onRefresh: () => _loadTasks(refresh: true),
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        color: theme.colorScheme.primary,
        child: _buildBody(theme),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          Text(
            _showAll ? 'All Tasks' : 'My Tasks',
            style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onPrimary.withAlpha(200)),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.filter_list,
              color: _filterStatus != null
                  ? Colors.amber
                  : theme.colorScheme.onPrimary,
            ),
          ),
          onSelected: (value) {
            setState(() {
              _filterStatus = value == 'all' ? null : value;
            });
            _loadTasks(refresh: true);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'all', child: Text('All Status')),
            const PopupMenuItem(value: 'assigned', child: Text('📋 Assigned')),
            const PopupMenuItem(
                value: 'in_progress', child: Text('⏳ In Progress')),
            const PopupMenuItem(value: 'completed', child: Text('✅ Completed')),
          ],
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: Size.square(60),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [Expanded(child: _buildStatsCard(theme))],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_tasks.length} Tasks',
            style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500),
          ),
          if (_filterStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withAlpha(75),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _filterStatus!.toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_error != null && _tasks.isEmpty) {
      return _buildErrorWidget(theme);
    }

    if (_tasks.isEmpty && _isLoading) {
      return _buildLoadingWidget(theme);
    }

    if (_tasks.isEmpty) {
      return _buildEmptyWidget(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _tasks.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _tasks.length) {
          return _buildLoadingItem(theme);
        }

        final task = _tasks[index];
        return _buildTaskCard(task, index, theme);
      },
    );
  }

  Widget _buildTaskCard(Task task, int index, ThemeData theme) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () async {
            await context.pushNamed(
              RouteNames.taskDetail,
              pathParameters: {'id': task.id.toString()},
            );
            _loadTasks(refresh: true);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: task.statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        task.statusIcon,
                        color: task.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title ?? 'Untitled Task',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: task.statusColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.statusDisplayName,
                              style: TextStyle(
                                color: task.statusColor.withAlpha(200),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                  ],
                ),
                const SizedBox(height: 16),
                if (task.description?.isNotEmpty == true) ...[
                  Text(
                    task.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                _buildTaskInfo(task, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo(Task task, ThemeData theme) {
    return Row(
      children: [
        if (task.assignedName?.isNotEmpty == true ||
            task.assignedTo.isNotEmpty) ...[
          Icon(Icons.person, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              task.assignedName ?? task.assignedTo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (task.targetDate != null) ...[
          const SizedBox(width: 12),
          Icon(Icons.schedule, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 4),
          Text(
            _formatDate(task.targetDate!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: task.isOverdue
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
        if (task.latitude != null && task.longitude != null) ...[
          const SizedBox(width: 12),
          Icon(Icons.location_on, size: 16, color: theme.colorScheme.outline),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tasks found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showAll
                ? 'There are no tasks available at the moment.'
                : 'You have no assigned tasks.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadTasks(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final difference = taskDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference < -1) return '${difference.abs()} days ago';
    if (difference > 1) return 'In $difference days';

    return '${date.day}/${date.month}/${date.year}';
  }
}
