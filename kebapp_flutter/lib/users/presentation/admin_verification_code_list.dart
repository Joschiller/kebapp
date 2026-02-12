import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/users/presentation/verification_code_display.dart';
import 'package:kebapp_flutter/users/state/verification_code_admin_cubit.dart';

class AdminVerificationCodeList extends StatelessWidget {
  const AdminVerificationCodeList({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<VerificationCodeAdminCubit, VerificationCodeAdminCubitState>(
        builder: (context, state) => switch (state) {
          VerificationCodeAdminCubitStateLoading() => Center(
              child: CircularProgressIndicator(),
            ),
          VerificationCodeAdminCubitStateNoPermission() => SizedBox.shrink(),
          VerificationCodeAdminCubitStateLoaded(
            verifications: final verifications
          ) =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Spacer(),
                            IconButton(
                              onPressed: context
                                  .read<VerificationCodeAdminCubit>()
                                  .reload,
                              icon: Icon(Icons.refresh),
                            ),
                          ],
                        ),
                        ExpansionPanelList.radio(
                          children: verifications
                              .map(
                                (e) => ExpansionPanelRadio(
                                  value: e.userId,
                                  headerBuilder: (context, isExpanded) =>
                                      ListTile(title: Text(e.userName)),
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(width: 8),
                                          VerificationCodeDisplay(
                                            verificationCode:
                                                e.verificationCode,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  canTapOnHeader: true,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        },
      );
}
