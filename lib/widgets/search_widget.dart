import 'package:flutter/material.dart';
import 'package:weather_app/model/favorite_city_model.dart';
import 'dart:async';

import 'package:weather_app/model/location_model.dart';

class SearchScreen extends StatefulWidget {
  final List<String> favoriteCities;
  final List<FavoriteCity> savedFavorites;
  final List<LocationModel> filteredCities;
  final Function(LocationModel) onCitySelected;
  final Function(FavoriteCity) onFavoriteSelected;
  final Function(FavoriteCity) onAddFavorite;
  final Function(LocationModel) onAddCity;
  final Function(String) onRemoveCity;
  final Function(String) onSearch;

  const SearchScreen({
    super.key,
    required this.filteredCities,
    required this.savedFavorites,
    required this.favoriteCities,
    required this.onCitySelected,
    required this.onAddFavorite,
    required this.onFavoriteSelected,
    required this.onAddCity,
    required this.onRemoveCity,
    required this.onSearch,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cari Kota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchTextChanged, // <-- gunakan onChanged
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari kota...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A3F50)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF5D5FEF),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2D3E),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.filteredCities.isEmpty
                  ? 'Lokasi Favorit'
                  : "Hasil Pencarian",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.filteredCities.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: widget.filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = widget.filteredCities[index];
                    return ListTile(
                      title: Text(
                        [city.name, city.state, city.country]
                            .where(
                              (part) => part != null && part.trim().isNotEmpty,
                            )
                            .join(', '),
                        style: const TextStyle(color: Colors.white),
                      ),
                      leading: Icon(
                        Icons.location_on,
                        color: const Color(0xFF5D5FEF),
                      ),
                      onTap: () => {
                        widget.onCitySelected(city),
                        _searchController.text = '',
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () => widget.onAddCity(city),
                      ),
                    );
                  },
                ),
              ),
            ] else if (widget.filteredCities.isEmpty &&
                widget.savedFavorites.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: widget.savedFavorites.length,
                  itemBuilder: (context, index) {
                    final city = widget.savedFavorites[index];
                    return ListTile(
                      title: Text(
                        city.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      leading: Icon(
                        Icons.location_on,
                        color: const Color(0xFF5D5FEF),
                      ),
                      onTap: () => widget.onFavoriteSelected(city),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => widget.onAddFavorite(city),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Image.asset('assets/building.png', width: 200, height: 200),
                    const SizedBox(height: 20),
                    const Text(
                      'Ketik nama kota untuk mencari...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
