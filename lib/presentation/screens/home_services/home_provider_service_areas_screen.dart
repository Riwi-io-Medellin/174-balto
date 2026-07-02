import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/home_provider_service_area.dart';
import '../../../domain/repositories/home_provider_service_area_repository.dart';

class HomeProviderServiceAreasScreen extends StatefulWidget {
  const HomeProviderServiceAreasScreen({super.key});

  @override
  State<HomeProviderServiceAreasScreen> createState() =>
      _HomeProviderServiceAreasScreenState();
}

class _AreaEntry {
  _AreaEntry({this.label, required this.latitude, required this.longitude, required this.radiusKm});
  String? label;
  double latitude;
  double longitude;
  double radiusKm;
}

class _HomeProviderServiceAreasScreenState
    extends State<HomeProviderServiceAreasScreen> {
  static const Color _accent = AppColors.homeServices;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textMuted = Color(0xFF8A93A0);

  List<_AreaEntry> _areas = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final areas =
          await sl<HomeProviderServiceAreaRepository>().getMyServiceAreas();
      setState(() {
        _areas = areas
            .map((a) => _AreaEntry(
                  label: a.label,
                  latitude: a.latitude,
                  longitude: a.longitude,
                  radiusKm: a.radiusKm,
                ))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to load service areas.');
      setState(() => _loading = false);
    }
  }

  void _addArea() {
    setState(() {
      _areas.add(_AreaEntry(latitude: 4.7110, longitude: -74.0721, radiusKm: 10));
    });
  }

  void _removeArea(int index) {
    setState(() => _areas.removeAt(index));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final areas = _areas
          .map((a) => HomeProviderServiceArea(
                label: a.label,
                latitude: a.latitude,
                longitude: a.longitude,
                radiusKm: a.radiusKm,
              ))
          .toList();
      await sl<HomeProviderServiceAreaRepository>().replaceMyServiceAreas(areas);
      if (!mounted) return;
      BaltoToast.success(context, 'Service areas saved successfully.');
      Navigator.of(context).pop();
    } on HomeProviderServiceAreaFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark),
        ),
        title: const Text(
          'Service Areas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _saving ? _textMuted : _accent,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add the zones you travel to. Clients within these areas will see you in search results.',
                    style: TextStyle(fontSize: 13, color: _textMid, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (_areas.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE0E4EC)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.map_outlined, size: 36, color: Color(0xFFB0B8C1)),
                          SizedBox(height: 8),
                          Text('No service areas yet', style: TextStyle(fontSize: 13, color: _textMuted)),
                        ],
                      ),
                    )
                  else
                    ..._areas.asMap().entries.map(
                          (entry) => _buildAreaCard(entry.key, entry.value),
                        ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addArea,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Area'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accent,
                        side: BorderSide(color: _accent.withValues(alpha: 0.30)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAreaCard(int index, _AreaEntry area) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.place_rounded, size: 18, color: _accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: area.label,
                  decoration: const InputDecoration(
                    hintText: 'Area label (e.g. Downtown)',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                  onChanged: (v) => area.label = v,
                ),
              ),
              GestureDetector(
                onTap: () => _removeArea(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Color(0xFFFFF0ED), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFD05A24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  label: 'Latitude',
                  initial: area.latitude.toString(),
                  onChanged: (v) => area.latitude = double.tryParse(v) ?? area.latitude,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _numberField(
                  label: 'Longitude',
                  initial: area.longitude.toString(),
                  onChanged: (v) => area.longitude = double.tryParse(v) ?? area.longitude,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _numberField(
            label: 'Radius (km)',
            initial: area.radiusKm.toString(),
            onChanged: (v) => area.radiusKm = double.tryParse(v) ?? area.radiusKm,
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initial,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _textMuted),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: const TextStyle(fontSize: 13, color: _textDark),
      onChanged: onChanged,
    );
  }
}
