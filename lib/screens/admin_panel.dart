import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSubject = 'Mathematics';
  String _topicName = '';
  String _description = '';
  String _numLessons = '';
  double _rating = 3.0;
  String _duration = '';
  String _imageUrl = '';
  String? _editDocumentId; // For updating
  String _selectedOperation = 'Create'; // Default operation

  final List<String> _subjects = [
    'Mathematics',
    'Geography',
    'History',
    'Science',
    'Hindi',
    'English',
    'Marathi'
  ];

  final List<String> _operations = ['Create', 'Read', 'Update', 'Delete'];

  // Method to refresh data
  void _refreshData() {
    setState(() {
      // This will trigger the FutureBuilder to fetch data again
    });
  }

  void _performOperation() async {
    switch (_selectedOperation) {
      case 'Create':
        _submitForm();
        break;
      case 'Read':
        // Read operation is handled by the FutureBuilder
        break;
      case 'Update':
        if (_editDocumentId != null) {
          _submitForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a topic to update.')),
          );
        }
        break;
      case 'Delete':
        if (_editDocumentId != null) {
          _deleteData(_editDocumentId!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a topic to delete.')),
          );
        }
        break;
      default:
        break;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a unique document ID by concatenating the subject and topic_name
      String documentId = _editDocumentId ?? '${_selectedSubject}_$_topicName';

      // Get the reference to Firestore collection 'admin' and create or update a document with the custom ID
      CollectionReference adminCollection =
          FirebaseFirestore.instance.collection('boards');

      try {
        // Add or update a document in the 'admin' collection with the custom ID
        await adminCollection.doc(documentId).set({
          'subject': _selectedSubject,
          'topic_name': _topicName,
          'description': _description,
          'num_lessons': _numLessons,
          'rating': _rating,
          'duration': _duration,
          'image_url': _imageUrl,
          'created_at': Timestamp.now(), // Adding a timestamp for reference
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topic Added/Updated Successfully!')),
        );

        // Reset the form and set _editDocumentId to null (indicating a new record)
        setState(() {
          _editDocumentId = null;
          _formKey.currentState?.reset();
        });

        _refreshData(); // Refresh the data after submission
      } catch (e) {
        print("Error adding/updating topic: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add/update topic. Please try again.')),
        );
      }
    }
  }

  void _fetchData(String documentId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc(documentId)
          .get();

      if (snapshot.exists) {
        setState(() {
          _selectedSubject = snapshot['subject'];
          _topicName = snapshot['topic_name'];
          _description = snapshot['description'];
          _numLessons = snapshot['num_lessons'];
          _rating = snapshot['rating'];
          _duration = snapshot['duration'];
          _imageUrl = snapshot['image_url'];
          _editDocumentId = documentId;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _deleteData(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Topic Deleted Successfully!')),
      );
      _refreshData(); // Refresh the data after deletion
    } catch (e) {
      print("Error deleting topic: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to delete topic. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white, // Light Gray Background
      appBar: AppBar(
        backgroundColor: Color(0xFF1D56CF), // Matching theme color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Admin Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Stronger emphasis
            fontSize: screenWidth * 0.05,
            color: Colors.white, // White text for better contrast
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown to select CRUD operation
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Operation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        DropdownButtonFormField(
                          value: _selectedOperation,
                          items: _operations.map((operation) {
                            return DropdownMenuItem(
                                value: operation,
                                child: Text(
                                  operation,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOperation = value.toString();
                              if (_selectedOperation != 'Update') {
                                _editDocumentId =
                                    null; // Reset edit document ID if not in Update mode
                              }
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedOperation == 'Update' ||
                    _selectedOperation == 'Read' ||
                    _selectedOperation == 'Delete') ...[
                  FutureBuilder(
                    future:
                        FirebaseFirestore.instance.collection('admin').get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No topics available.'));
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                                label: Text('Subject',
                                    style: TextStyle(color: Colors.black))),
                            DataColumn(
                                label: Text('Topic Name',
                                    style: TextStyle(color: Colors.black))),
                            DataColumn(
                                label: Text('Description',
                                    style: TextStyle(color: Colors.black))),
                            DataColumn(
                                label: Text('Lessons',
                                    style: TextStyle(color: Colors.black))),
                            DataColumn(
                                label: Text('Rating',
                                    style: TextStyle(color: Colors.black))),
                            DataColumn(
                                label: Text('Duration',
                                    style: TextStyle(color: Colors.black))),
                            DataColumn(
                                label: Text('Image URL',
                                    style: TextStyle(color: Colors.black))),
                            DataColumn(
                                label: Text('Actions',
                                    style: TextStyle(color: Colors.black))),
                          ],
                          rows: snapshot.data!.docs.map((doc) {
                            return DataRow(
                              cells: [
                                DataCell(Text(doc['subject'],
                                    style: TextStyle(color: Colors.black))),
                                DataCell(Text(doc['topic_name'],
                                    style: TextStyle(color: Colors.black))),
                                DataCell(Text(doc['description'],
                                    style: TextStyle(color: Colors.black))),
                                DataCell(Text(doc['num_lessons'],
                                    style: TextStyle(color: Colors.black))),
                                DataCell(Text(doc['rating'].toString(),
                                    style: TextStyle(color: Colors.black))),
                                DataCell(Text(doc['duration'],
                                    style: TextStyle(color: Colors.black))),
                                DataCell(Text(doc['image_url'],
                                    style: TextStyle(color: Colors.black))),
                                DataCell(
                                  Row(
                                    children: [
                                      if (_selectedOperation ==
                                          'Update') // Show edit icon only for Update
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Color(0xFF1D56CF)),
                                          onPressed: () {
                                            _fetchData(doc.id);
                                          },
                                        ),
                                      if (_selectedOperation ==
                                          'Delete') // Show delete icon only for Delete
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _deleteData(doc.id);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 20),
                // Form fields for Create and Update operations
                if (_selectedOperation == 'Create' ||
                    _selectedOperation == 'Update') ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Subject',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          DropdownButtonFormField(
                            value: _selectedSubject,
                            items: _subjects.map((subject) {
                              return DropdownMenuItem(
                                value: subject,
                                child: Text(
                                  subject,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubject = value.toString();
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),

                            decoration: InputDecoration(
                              labelText: 'Topic Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter topic name' : null,
                            onSaved: (value) => _topicName = value!,
                            controller: TextEditingController(
                                text:
                                    _topicName), // Pre-fill with existing data
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),

                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLines: 3,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter description' : null,
                            onSaved: (value) => _description = value!,
                            controller: TextEditingController(
                                text:
                                    _description), // Pre-fill with existing data
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),

                            decoration: InputDecoration(
                              labelText: 'Number of Lessons',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty
                                ? 'Enter number of lessons'
                                : null,
                            onSaved: (value) => _numLessons = value!,
                            controller: TextEditingController(
                                text:
                                    _numLessons), // Pre-fill with existing data
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rating: ${_rating.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Slider(
                            value: _rating,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            label: _rating.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),

                            decoration: InputDecoration(
                              labelText: 'Duration (mins)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter duration' : null,
                            onSaved: (value) => _duration = value!,
                            controller: TextEditingController(
                                text: _duration), // Pre-fill with existing data
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),

                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter image URL' : null,
                            onSaved: (value) => _imageUrl = value!,
                            controller: TextEditingController(
                                text: _imageUrl), // Pre-fill with existing data
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _performOperation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1D56CF),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _selectedOperation == 'Update'
                                    ? 'Update'
                                    : 'Submit',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // List Topics with Edit and Delete Options
              ],
            ),
          ),
        ),
      ),
    );
  }
}
