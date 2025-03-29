import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bike_provider.dart';
import '../../providers/fuel_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fuel_chart.dart';
import 'fuel_entry_screen.dart';

class FuelHistoryScreen extends StatefulWidget {
  const FuelHistoryScreen({super.key});

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshFuelData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshFuelData() async {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    if (bikeProvider.currentBike != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
        await fuelProvider.loadFuelEntries(bikeProvider.currentBike!.id!);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading fuel data: $error'),
            backgroundColor: AppColors.current.danger,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Entries'),
            Tab(text: 'Charts'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.current.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryList(),
                _buildCharts(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const FuelEntryScreen(),
            ),
          ).then((_) => _refreshFuelData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHistoryList() {
    final fuelProvider = Provider.of<FuelProvider>(context);
    final entries = fuelProvider.fuelEntries;

    if (entries.isEmpty) {
      return EmptyState(
        message: 'No fuel entries yet. Add your first fill-up to start tracking fuel economy.',
        icon: Icons.local_gas_station,
        actionLabel: 'Add Fill-Up',
        onActionPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const FuelEntryScreen()),
          ).then((_) => _refreshFuelData());
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFuelData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: entries.length,
        itemBuilder: (ctx, i) {
          final entry = entries[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => FuelEntryScreen(
                      entry: entry,
                      isEditing: true,
                    ),
                  ),
                ).then((_) => _refreshFuelData());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormatter.formatDate(entry.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormatter.formatCurrency(entry.totalCost),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.current.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Odometer',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.current.textLight,
                              ),
                            ),
                            Text(
                              DateFormatter.formatDistance(entry.odometer),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.current.textLight,
                              ),
                            ),
                            Text(
                              DateFormatter.formatVolume(entry.quantity),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price/L',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.current.textLight,
                              ),
                            ),
                            Text(
                              '\$${entry.costPerUnit.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            entry.fillType == FillType.full ? 'Full Tank' : 'Partial',
                          ),
                          backgroundColor: entry.fillType == FillType.full
                              ? AppColors.current.accent.withOpacity(0.2)
                              : AppColors.current.textLight.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: entry.fillType == FillType.full
                                ? AppColors.current.accent
                                : AppColors.current.textLight,
                          ),
                        ),
                        if (entry.efficiency != null)
                          Row(
                            children: [
                              Icon(
                                Icons.speed,
                                size: 16,
                                color: AppColors.current.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.formatEfficiency(entry.efficiency!),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.current.accent,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (entry.fuelType != null || entry.station != null) ...[
                      const SizedBox(height: 8),
                      Divider(color: AppColors.current.border),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (entry.fuelType != null) ...[
                            Icon(
                              Icons.local_gas_station,
                              size: 14,
                              color: AppColors.current.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.fuelType!,
                              style: TextStyle(
                                color: AppColors.current.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (entry.fuelType != null && entry.station != null) ...[
                            Text(
                              ' • ',
                              style: TextStyle(color: AppColors.current.textLight),
                            ),
                          ],
                          if (entry.station != null) ...[
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.current.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.station!,
                              style: TextStyle(
                                color: AppColors.current.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        entry.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.current.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharts() {
    final bikeProvider = Provider.of<BikeProvider>(context);
    final fuelProvider = Provider.of<FuelProvider>(context);

    if (!bikeProvider.hasBikes) {
      return EmptyState(
        message: 'Add your motorcycle to see fuel charts',
        icon: Icons.show_chart,
        actionLabel: 'Add Motorcycle',
        onActionPressed: () {},
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fuelProvider.getEfficiencyTrend(bikeProvider.currentBike!.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.current.accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading chart data: ${snapshot.error}',
              style: TextStyle(color: AppColors.current.danger),
            ),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return EmptyState(
            message: 'Need at least two full tank fill-ups to generate chart',
            icon: Icons.show_chart,
            actionLabel: 'Add Fill-Up',
            onActionPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const FuelEntryScreen()),
              ).then((_) => _refreshFuelData());
            },
          );
        }

        return Container(
          padding: const EdgeInsets.all(8.0),
          height: 300,
          child: FuelChart(
            data: data,
            title: 'Fuel Efficiency Trend (km/L)',
          ),
        );
      },
    );
  }
}
