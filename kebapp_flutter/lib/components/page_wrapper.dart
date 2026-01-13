import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/auth/sign_in_page.dart';
import 'package:kebapp_flutter/components/username_dialog.dart';
import 'package:kebapp_flutter/models/session_info.dart';
import 'package:kebapp_flutter/routes.dart';
import 'package:kebapp_flutter/users/state/session_info_cubit.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({
    super.key,
    required this.pageTitle,
    required this.builder,
    this.onUsernameChanged,
    this.floatingActionButton,
    this.onRefresh,
  });

  final String pageTitle;
  final Widget Function(BuildContext context) builder;
  final void Function()? onUsernameChanged;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SessionInfoCubit, SessionInfo?>(
        builder: (context, sessionInfo) => SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                [
                  'KebApp',
                  sessionInfo?.userName,
                ].nonNulls.join(' - '),
              ),
              actions: [
                if (sessionInfo != null)
                  IconButton(
                    onPressed: () => showDialog<bool>(
                      context: context,
                      builder: (context) => UsernameDialog(),
                    ).then((value) {
                      if (value ?? false) onUsernameChanged?.call();
                    }),
                    icon: Icon(Icons.badge_outlined),
                  ),
                if (sessionInfo?.isAdmin ?? false)
                  IconButton(
                    onPressed: () => AdminOverviewRoute().push(context),
                    icon: Icon(Icons.settings),
                  ),
                if (sessionInfo != null)
                  IconButton(
                    onPressed: context.read<SessionInfoCubit>().doSignout,
                    icon: Icon(Icons.logout),
                  )
              ],
            ),
            floatingActionButton: floatingActionButton,
            body: sessionInfo != null
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  pageTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ),
                            if (onRefresh != null)
                              IconButton(
                                onPressed: onRefresh,
                                icon: Icon(Icons.refresh),
                              ),
                          ],
                        ),
                      ),
                      Divider(),
                      Expanded(child: builder(context)),
                    ],
                  )
                : SignInPage(),
          ),
        ),
      );
}
