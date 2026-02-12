import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/meals/presentation/admin_meal_list.dart';
import 'package:kebapp_flutter/meals/state/meal_admin_cubit.dart';
import 'package:kebapp_flutter/models/session_info.dart';
import 'package:kebapp_flutter/users/presentation/admin_user_list.dart';
import 'package:kebapp_flutter/components/page_wrapper.dart';
import 'package:kebapp_flutter/components/single_expansion_tile_list.dart';
import 'package:kebapp_flutter/users/presentation/admin_verification_code_list.dart';
import 'package:kebapp_flutter/users/state/session_info_cubit.dart';
import 'package:kebapp_flutter/users/state/user_admin_cubit.dart';
import 'package:kebapp_flutter/users/state/verification_code_admin_cubit.dart';

class AdminOverview extends StatelessWidget {
  AdminOverview({super.key});

  final _userListyKey = GlobalKey<AdminUserListState>();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => VerificationCodeAdminCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => UserAdminCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => MealAdminCubit(),
            lazy: false,
          ),
        ],
        child: PageWrapper(
          pageTitle: 'Admin Menu',
          onUsernameChanged: () {
            context.read<UserAdminCubit>().reload();
            context.read<MealAdminCubit>().reload();
          },
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<SessionInfoCubit, SessionInfo?>(
                builder: (context, sessionInfo) =>
                    SingleExpansionTileList(children: {
                      if (sessionInfo?.canViewPendingVerifications ?? false)
                        'Pending Verification Codes':
                            AdminVerificationCodeList(),
                      if (sessionInfo?.canConfigureRights ?? false)
                        'Users': AdminUserList(
                          key: _userListyKey,
                        ),
                      if (sessionInfo?.canConfigureMeals ?? false)
                        'Meals': AdminMealList(),
                    })),
          ),
        ),
      );
}
