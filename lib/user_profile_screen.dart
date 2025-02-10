import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rosedine/url_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'auth.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isVegan = false;
  bool _isVegetarian = false;
  bool _isGlutenFree = false;

  Map<String, Map<String, int>> _macros = {
    'Breakfast': {'Protein': 0, 'Carbohydrates': 0, 'Fat': 0, 'Calories': 0},
    'Lunch': {'Protein': 0, 'Carbohydrates': 0, 'Fat': 0, 'Calories': 0},
    'Brunch': {'Protein': 0, 'Carbohydrates': 0, 'Fat': 0, 'Calories': 0},
    'Dinner': {'Protein': 0, 'Carbohydrates': 0, 'Fat': 0, 'Calories': 0},
  };

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final userId = await _getUserId();
    final url = Uri.parse(Config.getUrl('userPreferences', {'userId': userId}));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Data received: $data");
      setState(() {
        _isVegan = data['IsVegan'] ?? false;
        _isVegetarian = data['IsVegetarian'] ?? false;
        _isGlutenFree = data['IsGlutenFree'] ?? false;

        _macros['Breakfast']?['Protein'] = data['BreakfastProtein'] ?? 0;
        _macros['Breakfast']?['Carbohydrates'] =
            data['BreakfastCarbohydrates'] ?? 0;
        _macros['Breakfast']?['Fat'] = data['BreakfastFat'] ?? 0;
        _macros['Breakfast']?['Calories'] = data['BreakfastCalories'] ?? 0;

        _macros['Lunch']?['Protein'] = data['LunchProtein'] ?? 0;
        _macros['Lunch']?['Carbohydrates'] = data['LunchCarbohydrates'] ?? 0;
        _macros['Lunch']?['Fat'] = data['LunchFat'] ?? 0;
        _macros['Lunch']?['Calories'] = data['LunchCalories'] ?? 0;

        _macros['Dinner']?['Protein'] = data['DinnerProtein'] ?? 0;
        _macros['Dinner']?['Carbohydrates'] = data['DinnerCarbohydrates'] ?? 0;
        _macros['Dinner']?['Fat'] = data['DinnerFat'] ?? 0;
        _macros['Dinner']?['Calories'] = data['DinnerCalories'] ?? 0;

        _macros['Brunch']?['Protein'] = data['BrunchProtein'] ?? 0;
        _macros['Brunch']?['Carbohydrates'] = data['BrunchCarbohydrates'] ?? 0;
        _macros['Brunch']?['Fat'] = data['BrunchFat'] ?? 0;
        _macros['Brunch']?['Calories'] = data['BrunchCalories'] ?? 0;
      });
    } else {
      // Handle error
      print('Failed to load user preferences');
    }
  }

  Future<void> _updateDietaryRestriction(
      String restrictionName, bool restrictionValue) async {
    final userId = await _getUserId();
    final url = Uri.parse(Config.getUrl('updateDietaryRestriction', {
      'userId': userId,
      'restrictionName': restrictionName,
      'restrictionValue': restrictionValue.toString()
    }));
    final response = await http.put(url);

    if (response.statusCode == 200) {
      // Dietary restriction updated successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dietary restriction updated successfully')),
      );
    } else {
      // Failed to update dietary restriction
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update dietary restriction')),
      );
    }
  }

  Future<void> _updateMacro(
      String mealType, String macroName, int macroValue) async {
    final userId = await _getUserId();
    final url = Uri.parse(Config.getUrl('updateMacro', {
      'userId': userId,
      'mealType': mealType,
      'macroName': macroName,
      'macroValue': macroValue.toString()
    }));
    final response = await http.put(url);

    if (response.statusCode != 200) {
      // Only show SnackBar if there's an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update macro')),
      );
    }
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Color(0xFFAB8532),
        scaffoldBackgroundColor: Colors.blueGrey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: const Color(0xFFAB8532),
          inactiveTrackColor: Colors.grey,
          thumbColor: const Color(0xFFAB8532),
          overlayColor: const Color(0x29AB8532),
          valueIndicatorColor: const Color(0xFFAB8532),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('userId');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                );
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildPreferenceToggle('Vegan', _isVegan, (value) {
                setState(() {
                  _isVegan = value;
                });
                _updateDietaryRestriction('IsVegan', value);
              }),
              _buildPreferenceToggle('Vegetarian', _isVegetarian, (value) {
                setState(() {
                  _isVegetarian = value;
                });
                _updateDietaryRestriction('IsVegetarian', value);
              }),
              _buildPreferenceToggle('GlutenFree', _isGlutenFree, (value) {
                setState(() {
                  _isGlutenFree = value;
                });
                _updateDietaryRestriction('IsGlutenFree', value);
              }),
              const SizedBox(height: 24),
              Text(
                'Nutritional Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildMacroSection('Breakfast'),
              _buildMacroSection('Lunch'),
              _buildMacroSection('Brunch'),
              _buildMacroSection('Dinner'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceToggle(
      String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Color(0xFFAB8532),
      inactiveThumbColor: Color(0xFFAB8532),
      inactiveTrackColor: Colors.white,
    );
  }

  Widget _buildMacroSection(String mealType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealType,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        _buildMacroSlider(mealType, 'Protein', _macros[mealType]!['Protein']!,
            (value) {
          setState(() {
            _macros[mealType]!['Protein'] = value.round();
          });
          _updateMacro(mealType, 'Protein', value.round());
        }, 120),
        _buildMacroSlider(
            mealType, 'Carbohydrates', _macros[mealType]!['Carbohydrates']!,
            (value) {
          setState(() {
            _macros[mealType]!['Carbohydrates'] = value.round();
          });
          _updateMacro(mealType, 'Carbohydrates', value.round());
        }, 240),
        _buildMacroSlider(mealType, 'Fat', _macros[mealType]!['Fat']!, (value) {
          setState(() {
            _macros[mealType]!['Fat'] = value.round();
          });
          _updateMacro(mealType, 'Fat', value.round());
        }, 120),
        _buildMacroSlider(mealType, 'Calories', _macros[mealType]!['Calories']!,
            (value) {
          setState(() {
            _macros[mealType]!['Calories'] = value.round();
          });
          _updateMacro(mealType, 'Calories', value.round());
        }, 1200),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMacroSlider(String mealType, String macroName, int value,
      ValueChanged<double> onChanged, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$macroName: $value',
          style: TextStyle(fontSize: 16),
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
