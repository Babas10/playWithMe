// Displays a list of groups that the current user is a member of with real-time updates
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_state.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_creation_page.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_details_page.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_list_item.dart';
import 'package:play_with_me/features/groups/presentation/widgets/empty_group_list.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class GroupListPage extends StatelessWidget {
  final GroupBloc? blocOverride; // Optional bloc for testing

  const GroupListPage({super.key, this.blocOverride});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.myGroups),
            ),
            body: Center(
              child: Text(AppLocalizations.of(context)!.pleaseLogInToViewGroups),
            ),
          );
        }


        // BLoC is now provided by HomePage, just use it
        if (blocOverride != null) {
          return BlocProvider<GroupBloc>.value(
            value: blocOverride!,
            child: _buildScaffold(context, authState),
          );
        }

        // Use Builder to get a new context that includes the GroupBloc from HomePage
        return Builder(
          builder: (builderContext) => _buildScaffold(builderContext, authState),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, AuthenticationAuthenticated authState) {
    return Scaffold(
      body: BlocBuilder<GroupBloc, GroupState>(
              builder: (context, groupState) {
                if (groupState is GroupLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (groupState is GroupError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.errorLoadingGroups,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            groupState.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            context.read<GroupBloc>().add(
                              LoadGroupsForUser(userId: authState.user.uid),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (groupState is GroupsLoaded) {
                  for (var i = 0; i < groupState.groups.length; i++) {
                  }
                  if (groupState.groups.isEmpty) {
                    return const EmptyGroupList();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<GroupBloc>().add(
                        LoadGroupsForUser(userId: authState.user.uid),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupState.groups.length,
                      itemBuilder: (context, index) {
                        final group = groupState.groups[index];
                        return GroupListItem(
                          group: group,
                          onTap: () => _navigateToGroupDetails(context, group),
                        );
                      },
                    ),
                  );
                }

                // Initial state or other states
                return const EmptyGroupList();
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateGroup(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.createGroup),
      ),
    );
  }

  void _navigateToGroupDetails(BuildContext context, GroupModel group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(groupId: group.id),
      ),
    );
  }

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<GroupBloc>(),
          child: const GroupCreationPage(),
        ),
      ),
    );
    // No need to manually reload - the Firestore stream will automatically
    // emit the new group when it's created
  }
}
