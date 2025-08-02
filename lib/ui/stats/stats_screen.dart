import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/usecase/get_histories_by_month_usecase.dart';
import 'stats_view.dart';
import 'stats_viewmodel.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatsViewModel(
        getHistoriesByMonthUseCase: context.read<GetHistoriesByMonthUseCase>(),
      ),
      child: const StatsView(),
    );
  }
}