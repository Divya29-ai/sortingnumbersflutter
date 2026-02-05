// main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Main function to run the app
void main() {
  runApp(const MyApp());
}

// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Sorting Algorithm Visualizer',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[800],
        ),
        body: const SortVisualizer(),
      ),
    );
  }
}

// The main StatefulWidget for our visualizer
class SortVisualizer extends StatefulWidget {
  const SortVisualizer({super.key});

  @override
  State<SortVisualizer> createState() => _SortVisualizerState();
}

class _SortVisualizerState extends State<SortVisualizer> {
  List<int> _numbers = [];
  bool _isSorting = false;
  
  // State for user controls
  double _arraySize = 10;
  double _animationSpeed = 500;
  String _currentAlgorithm = 'Bubble Sort';
  
  // State for visualization logic
  int _currentIndex = -1;
  int _nextIndex = -1;
  int _sortedCount = 0; 
  String _explanationText = "Select an algorithm and click 'Shuffle'.";
  
  // State for performance metrics
  int _comparisonCount = 0;
  int _swapCount = 0; // Represents swaps or array writes
  
  // State specific to algorithms
  int _minIndex = -1; // For Selection Sort
  int _mergeLeftIndex = -1; // For Merge Sort
  int _mergeRightIndex = -1; // For Merge Sort

  final List<String> _algorithms = ['Bubble Sort', 'Selection Sort', 'Merge Sort'];

  // Data store for algorithm information
  final Map<String, Map<String, String>> _algorithmInfo = {
    'Bubble Sort': {
      'description': 'A simple algorithm that repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order.',
      'time_best': 'O(n)', 'time_avg': 'O(n²)', 'time_worst': 'O(n²)',
    },
    'Selection Sort': {
      'description': 'An in-place algorithm that repeatedly finds the minimum element from the unsorted part and moves it to the sorted part.',
      'time_best': 'O(n²)', 'time_avg': 'O(n²)', 'time_worst': 'O(n²)',
    },
    'Merge Sort': {
      'description': 'An efficient, recursive "divide and conquer" algorithm. It divides the array into halves, sorts them, and then merges them back together.',
      'time_best': 'O(n log n)', 'time_avg': 'O(n log n)', 'time_worst': 'O(n log n)',
    },
  };

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    setState(() {
      _numbers = List<int>.generate(_arraySize.toInt(), (i) => i + 1)..shuffle();
      _isSorting = false;
      _resetVisualsAfterSort(resetText: false); 
      _explanationText = "Ready to sort with $_currentAlgorithm.";
    });
  }
  
  void _startSort() {
    if (_isSorting) return;
    setState(() {
      _comparisonCount = 0;
      _swapCount = 0;
      _sortedCount = 0;
    });

    if (_currentAlgorithm == 'Bubble Sort') _bubbleSort();
    else if (_currentAlgorithm == 'Selection Sort') _selectionSort();
    else if (_currentAlgorithm == 'Merge Sort') _mergeSort(0, _numbers.length - 1);
  }

  Future<void> _bubbleSort() async {
    setState(() { _isSorting = true; });

    for (int i = 0; i < _numbers.length; i++) {
      for (int j = 0; j < _numbers.length - i - 1; j++) {
        if (!mounted) return;
        setState(() {
          _currentIndex = j;
          _nextIndex = j + 1;
          _explanationText = "Comparing ${_numbers[j]} and ${_numbers[j+1]}.";
          _comparisonCount++;
        });
        await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));

        if (_numbers[j] > _numbers[j + 1]) {
          setState(() {
            _explanationText = "Swapping ${_numbers[j]} and ${_numbers[j+1]}.";
            _swapCount++;
            int temp = _numbers[j];
            _numbers[j] = _numbers[j + 1];
            _numbers[j + 1] = temp;
          });
          await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));
        }
      }
      setState(() { _sortedCount = i + 1; });
    }
    _resetVisualsAfterSort();
  }

  Future<void> _selectionSort() async {
    setState(() { _isSorting = true; });

    for (int i = 0; i < _numbers.length - 1; i++) {
      _minIndex = i;
      setState(() {
        _currentIndex = i;
        _explanationText = "Pass ${i + 1}: Finding smallest value...";
      });
       await Future.delayed(Duration(milliseconds: (_animationSpeed * 1.5).toInt()));

      for (int j = i + 1; j < _numbers.length; j++) {
        if (!mounted) return;
        setState(() {
          _nextIndex = j;
          _explanationText = "Comparing ${_numbers[_minIndex]} and ${_numbers[j]}.";
          _comparisonCount++;
        });
        await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));
        
        if (_numbers[j] < _numbers[_minIndex]) {
          setState(() {
            _minIndex = j;
            _explanationText = "Found new minimum: ${_numbers[_minIndex]}.";
          });
          await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));
        }
      }

      if (_minIndex != i) {
        setState(() {
          _explanationText = "Swapping ${_numbers[i]} with ${_numbers[_minIndex]}.";
          _swapCount++;
          int temp = _numbers[i];
          _numbers[i] = _numbers[_minIndex];
          _numbers[_minIndex] = temp;
        });
        await Future.delayed(Duration(milliseconds: (_animationSpeed * 1.5).toInt()));
      }
      setState(() { _sortedCount = i + 1; });
    }
    _resetVisualsAfterSort();
  }
  
  Future<void> _mergeSort(int left, int right) async {
    setState(() { _isSorting = true; });
    await _mergeSortHelper(left, right);
    _resetVisualsAfterSort();
  }

  Future<void> _mergeSortHelper(int left, int right) async {
    if (left < right && _isSorting) {
      int mid = (left + right) ~/ 2;
      setState(() {
        _explanationText = "Dividing the array...";
        _mergeLeftIndex = left;
        _mergeRightIndex = right;
      });
      await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));

      await _mergeSortHelper(left, mid);
      await _mergeSortHelper(mid + 1, right);
      await _merge(left, mid, right);
    }
  }

  Future<void> _merge(int left, int mid, int right) async {
    if (!_isSorting) return;
    setState(() {
      _explanationText = "Merging subarrays...";
      _mergeLeftIndex = left;
      _mergeRightIndex = right;
    });
    await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));
    
    List<int> leftArr = _numbers.sublist(left, mid + 1);
    List<int> rightArr = _numbers.sublist(mid + 1, right + 1);
    
    int i = 0, j = 0, k = left;
    
    while(i < leftArr.length && j < rightArr.length) {
      if (!mounted || !_isSorting) return;
      setState(() { _comparisonCount++; });
      if (leftArr[i] <= rightArr[j]) {
        _numbers[k] = leftArr[i];
        i++;
      } else {
        _numbers[k] = rightArr[j];
        j++;
      }
      setState(() {
        _swapCount++;
        _currentIndex = k;
      });
      await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));
      k++;
    }

    while (i < leftArr.length) {
      if (!mounted || !_isSorting) return;
      _numbers[k] = leftArr[i];
      setState(() {
        _swapCount++;
        _currentIndex = k;
      });
      await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));
      i++;
      k++;
    }

    while (j < rightArr.length) {
      if (!mounted || !_isSorting) return;
      _numbers[k] = rightArr[j];
      setState(() {
        _swapCount++;
        _currentIndex = k;
      });
      await Future.delayed(Duration(milliseconds: _animationSpeed.toInt()));
      j++;
      k++;
    }
  }

  void _resetVisualsAfterSort({bool resetText = true}) {
    setState(() {
      _isSorting = false;
      _currentIndex = -1;
      _nextIndex = -1;
      _minIndex = -1;
      _mergeLeftIndex = -1;
      _mergeRightIndex = -1;
      _sortedCount = _numbers.length;
      if (resetText) {
        _explanationText = "Sorting complete! Click 'Shuffle' to reset.";
      }
    });
  }

  Widget _buildInfoPanel() {
    final info = _algorithmInfo[_currentAlgorithm]!;
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(info['description']!, style: const TextStyle(fontSize: 14)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Best Case: ${info['time_best']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Average: ${info['time_avg']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Worst Case: ${info['time_worst']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double barWidth = max(1, (screenWidth - 32) / (_arraySize * 2));
    double maxHeight = MediaQuery.of(context).size.height * 0.3;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            height: 50,
            child: Text(
              _explanationText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: maxHeight + 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _numbers.asMap().entries.map((entry) {
                int index = entry.key;
                int number = entry.value;

                Color barColor = Colors.blue;
                if (_isSorting && _sortedCount == _numbers.length) {
                  barColor = Colors.green;
                } else if (index < _sortedCount && _currentAlgorithm != "Merge Sort") {
                  barColor = Colors.green;
                } else if (_isSorting && _currentAlgorithm == "Merge Sort" && index >= _mergeLeftIndex && index <= _mergeRightIndex) {
                  barColor = Colors.orange;
                } else if (index == _currentIndex || index == _nextIndex) {
                  barColor = Colors.red;
                } else if (index == _minIndex) {
                  barColor = Colors.yellow;
                } else if (_isSorting) {
                  barColor = Colors.grey.shade400;
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: number.toDouble() * (maxHeight / _arraySize),
                      width: barWidth,
                      margin: EdgeInsets.symmetric(horizontal: barWidth > 2 ? 1: 0.5),
                      decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4)),
                    ),
                    if (_arraySize <= 25) ...[
                      const SizedBox(height: 5), Text(number.toString(), style: TextStyle(fontSize: max(8, barWidth / 2.5))),
                    ]
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Comparisons: $_comparisonCount", style: const TextStyle(fontSize: 16)),
              Text("Writes: $_swapCount", style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _isSorting ? null : _shuffle, child: const Text('Shuffle')),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _currentAlgorithm,
                items: _algorithms.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: _isSorting ? null : (String? newValue) {
                  setState(() {
                    _currentAlgorithm = newValue!;
                    _shuffle();
                  });
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _isSorting ? null : _startSort, child: const Text('Sort')),
            ],
          ),
          Text("Animation Speed: ${_animationSpeed.toInt()} ms"),
          Slider(
            value: _animationSpeed, min: 0, max: 1000, divisions: 20,
            label: _animationSpeed.round().toString(),
            onChanged: (double value) { setState(() { _animationSpeed = value; }); },
          ),
          Text("Array Size: ${_arraySize.toInt()}"),
          Slider(
            value: _arraySize, min: 5, max: 100, divisions: 19,
            label: _arraySize.round().toString(),
            onChanged: _isSorting ? null : (double value) {
              setState(() {
                _arraySize = value;
                _shuffle();
              });
            },
          ),
          _buildInfoPanel(),
        ],
      ),
    );
  }
}