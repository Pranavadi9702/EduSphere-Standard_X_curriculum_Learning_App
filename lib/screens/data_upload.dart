import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchDailyFacts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('daily_facts').get();
      return snapshot.docs.map((doc) => doc['fact'] as String).toList();
    } catch (e) {
      debugPrint("❌ Error fetching facts from Firestore: $e");
      return [];
    }
  }

  Future<void> addSubjectDescription(
      String board, String subject, String description) async {
    try {
      await FirebaseFirestore.instance
          .collection('boards')
          .doc(board) // 🔹 Select board (ICSE, CBSE, etc.)
          .collection('subjects')
          .doc(subject) // 🔹 Select subject (Economics, Geography, etc.)
          .set({
        "description": description, // ✅ Add description
      }, SetOptions(merge: true)); // 🔹 Prevent overwriting existing data

      debugPrint("✅ Description added for $subject under $board!");
    } catch (e) {
      debugPrint("❌ Error adding description: $e");
    }
  }

  void addDescriptionsForAllBoards() {
    Map<String, String> subjects = {
      "Economics":
          "Economics studies production, distribution, and consumption of goods and services.",
      "Geography":
          "Geography explores Earth's physical features and human-environment interactions.",
      "History":
          "History examines past events, civilizations, and their impacts on modern society.",
      "Mathematics":
          "Mathematics deals with numbers, formulas, shapes, and logical reasoning.",
      "Science":
          "Science investigates natural phenomena, experiments, and technological advancements.",
    };

    List<String> boards = ["ICSE", "CBSE", "IGCSE", "SSC"];

    for (String board in boards) {
      subjects.forEach((subject, description) {
        addSubjectDescription(board, subject, description);
      });
    }
  }

// // Function to upload quiz data
//   Future<void> uploadQuizData() async {
//     CollectionReference quizCollection = _firestore
//         .collection('boards')
//         .doc('ICSE')
//         .collection('subjects')
//         .doc('Mathematics')
//         .collection('chapters')
//         .doc('1')
//         .collection('quiz');

//     List<Map<String, String>> quizData = [
//       {
//         "question": "What is the value of (√25 + √9) × (√16 - √4) ?",
//         "option1": "20",
//         "option2": "24",
//         "option3": "28",
//         "option4": "30",
//         "correct_answer": "24"
//       },
//       {
//         "question":
//             "If the sum of the angles of a triangle is 180°, what is the sum of the angles of a quadrilateral?",
//         "option1": "180°",
//         "option2": "270°",
//         "option3": "360°",
//         "option4": "450°",
//         "correct_answer": "360°"
//       },
//       {
//         "question": "What is the value of (3² + 4²) ?",
//         "option1": "9",
//         "option2": "16",
//         "option3": "25",
//         "option4": "7",
//         "correct_answer": "25"
//       },
//       {
//         "question": "The area of a circle is given by which formula?",
//         "option1": "πr²",
//         "option2": "2πr",
//         "option3": "πd",
//         "option4": "2r",
//         "correct_answer": "πr²"
//       },
//       {
//         "question":
//             "If a = 5 and b = 12, what is the value of c in the right-angled triangle where c is the hypotenuse?",
//         "option1": "10",
//         "option2": "12",
//         "option3": "13",
//         "option4": "15",
//         "correct_answer": "13"
//       },
//       {
//         "question": "What is the cube root of 64?",
//         "option1": "2",
//         "option2": "4",
//         "option3": "8",
//         "option4": "16",
//         "correct_answer": "4"
//       },
//       {
//         "question": "What is the LCM of 12 and 18?",
//         "option1": "24",
//         "option2": "30",
//         "option3": "36",
//         "option4": "48",
//         "correct_answer": "36"
//       },
//       {
//         "question": "Which of the following is a Pythagorean triplet?",
//         "option1": "3, 4, 5",
//         "option2": "5, 6, 7",
//         "option3": "6, 7, 8",
//         "option4": "8, 9, 10",
//         "correct_answer": "3, 4, 5"
//       },
//       {
//         "question": "What is the value of 2^5?",
//         "option1": "16",
//         "option2": "32",
//         "option3": "64",
//         "option4": "128",
//         "correct_answer": "32"
//       },
//       {
//         "question":
//             "A number is divisible by 6 if it is divisible by which two numbers?",
//         "option1": "2 and 3",
//         "option2": "3 and 4",
//         "option3": "4 and 5",
//         "option4": "5 and 6",
//         "correct_answer": "2 and 3"
//       }
//     ];

//     WriteBatch batch = _firestore.batch();

//     for (int i = 0; i < quizData.length; i++) {
//       String docId = "Q${i + 1}"; // Naming documents as Q1, Q2, etc.
//       batch.set(quizCollection.doc(docId), quizData[i]);
//     }

//     await batch.commit();
//     print("Quiz data uploaded successfully!");
//   }

  // Future<void> uploadSSCGeographyFlashcardData() async {
  //   // Chapter-wise flashcard data (5 flashcards per chapter)
  //   Map<String, List<Map<String, String>>> chaptersFlashcardData = {
  //     "1": [
  //       {
  //         "front": "What is Geography?",
  //         "back":
  //             "Geography is the study of Earth's landscapes, environments, and the relationships between people and their surroundings."
  //       },
  //       {
  //         "front": "What are the two main branches of Geography?",
  //         "back": "Physical Geography and Human Geography."
  //       },
  //       {
  //         "front": "What is the shape of the Earth?",
  //         "back": "The Earth is an oblate spheroid."
  //       },
  //       {
  //         "front": "What is a continent?",
  //         "back": "A large continuous mass of land; there are seven continents."
  //       },
  //       {
  //         "front": "Which is the largest continent?",
  //         "back": "Asia is the largest continent."
  //       }
  //     ],
  //     "2": [
  //       {
  //         "front": "What is the Earth's crust made of?",
  //         "back": "The Earth's crust is made of rocks and minerals."
  //       },
  //       {
  //         "front": "What are the three main types of rocks?",
  //         "back": "Igneous, Sedimentary, and Metamorphic rocks."
  //       },
  //       {
  //         "front": "What is the process of weathering?",
  //         "back":
  //             "Weathering is the breaking down of rocks by natural forces like wind, water, and temperature changes."
  //       },
  //       {
  //         "front": "What is a volcano?",
  //         "back":
  //             "A volcano is an opening in the Earth's crust that allows molten rock, ash, and gases to escape."
  //       },
  //       {
  //         "front": "What is an earthquake?",
  //         "back":
  //             "An earthquake is the shaking of the Earth's surface caused by movement along fault lines."
  //       }
  //     ],
  //     "3": [
  //       {
  //         "front": "What is a river?",
  //         "back":
  //             "A river is a large natural stream of water flowing towards a sea, lake, or another river."
  //       },
  //       {
  //         "front": "What are the three stages of a river?",
  //         "back": "Youthful stage, Mature stage, and Old stage."
  //       },
  //       {
  //         "front": "What is the longest river in India?",
  //         "back": "The Ganges is the longest river in India."
  //       },
  //       {
  //         "front": "What is a delta?",
  //         "back":
  //             "A delta is a landform created at the mouth of a river where it deposits sediments."
  //       },
  //       {
  //         "front": "What is the difference between a sea and an ocean?",
  //         "back": "An ocean is larger and deeper than a sea."
  //       }
  //     ],
  //     "4": [
  //       {
  //         "front": "What are natural resources?",
  //         "back":
  //             "Natural resources are materials or substances that occur in nature and can be used for economic gain."
  //       },
  //       {
  //         "front": "What are renewable resources?",
  //         "back":
  //             "Resources that can be replenished naturally, such as sunlight and wind."
  //       },
  //       {
  //         "front": "What are non-renewable resources?",
  //         "back":
  //             "Resources that cannot be replenished quickly, such as coal and petroleum."
  //       },
  //       {
  //         "front": "What is deforestation?",
  //         "back": "The large-scale clearing of forests for human activities."
  //       },
  //       {
  //         "front": "What is soil erosion?",
  //         "back":
  //             "The wearing away of topsoil due to wind, water, or human activities."
  //       }
  //     ],
  //     "5": [
  //       {
  //         "front": "What is population density?",
  //         "back": "The number of people living per square kilometer."
  //       },
  //       {
  //         "front": "What are the factors affecting population distribution?",
  //         "back":
  //             "Climate, availability of water, soil fertility, and economic opportunities."
  //       },
  //       {
  //         "front": "What is migration?",
  //         "back":
  //             "The movement of people from one place to another for better living conditions."
  //       },
  //       {
  //         "front": "What are urban and rural areas?",
  //         "back":
  //             "Urban areas are cities and towns, while rural areas are villages and countryside."
  //       },
  //       {
  //         "front": "What is the literacy rate?",
  //         "back":
  //             "The percentage of people who can read and write in a particular region."
  //       }
  //     ],
  //     "6": [
  //       {
  //         "front": "What is agriculture?",
  //         "back":
  //             "The practice of cultivating plants and rearing animals for food, fiber, and other products."
  //       },
  //       {
  //         "front": "What are the types of farming?",
  //         "back": "Subsistence farming and commercial farming."
  //       },
  //       {
  //         "front": "What is irrigation?",
  //         "back": "The artificial supply of water to crops."
  //       },
  //       {
  //         "front": "What is organic farming?",
  //         "back":
  //             "A farming method that avoids synthetic fertilizers and pesticides."
  //       },
  //       {
  //         "front": "What are cash crops?",
  //         "back": "Crops grown for sale, such as cotton, tea, and coffee."
  //       }
  //     ],
  //     "7": [
  //       {
  //         "front": "What are minerals?",
  //         "back":
  //             "Natural substances found in rocks that are useful for humans."
  //       },
  //       {
  //         "front": "What are metallic minerals?",
  //         "back":
  //             "Minerals that contain metals, such as iron, copper, and gold."
  //       },
  //       {
  //         "front": "What are non-metallic minerals?",
  //         "back":
  //             "Minerals that do not contain metals, such as limestone and gypsum."
  //       },
  //       {
  //         "front": "What is coal used for?",
  //         "back":
  //             "Coal is used as a fuel for electricity generation and industrial processes."
  //       },
  //       {
  //         "front": "What is the main source of energy in India?",
  //         "back": "Coal and hydropower are the major sources of energy."
  //       }
  //     ],
  //     "8": [
  //       {
  //         "front": "What is transport?",
  //         "back": "The movement of people and goods from one place to another."
  //       },
  //       {
  //         "front": "What are the main modes of transport?",
  //         "back": "Road, Rail, Water, and Air transport."
  //       },
  //       {
  //         "front": "What is the longest railway network in the world?",
  //         "back": "The Trans-Siberian Railway in Russia."
  //       },
  //       {
  //         "front": "What are the advantages of air transport?",
  //         "back":
  //             "It is the fastest mode of transport and is useful for long distances."
  //       },
  //       {
  //         "front": "What is public transport?",
  //         "back":
  //             "Transport services available for use by the general public, such as buses and trains."
  //       }
  //     ],
  //     "9": [
  //       {
  //         "front": "What is environmental pollution?",
  //         "back":
  //             "The contamination of the environment due to human activities."
  //       },
  //       {
  //         "front": "What are the types of pollution?",
  //         "back": "Air, Water, Soil, and Noise pollution."
  //       },
  //       {
  //         "front": "What causes global warming?",
  //         "back":
  //             "The increase in greenhouse gases like CO₂ due to burning fossil fuels."
  //       },
  //       {
  //         "front": "What is sustainable development?",
  //         "back":
  //             "Development that meets present needs without compromising future generations."
  //       },
  //       {
  //         "front": "What are some ways to reduce pollution?",
  //         "back":
  //             "Using renewable energy, recycling, planting trees, and reducing waste."
  //       }
  //     ]
  //   };

  //   WriteBatch batch = _firestore.batch();

  //   for (String chapterId in chaptersFlashcardData.keys) {
  //     CollectionReference flashcardCollection = _firestore
  //         .collection('boards')
  //         .doc('SSC')
  //         .collection('subjects')
  //         .doc('Geography')
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .collection('flashcards');

  //     List<Map<String, String>> flashcardData =
  //         chaptersFlashcardData[chapterId]!;

  //     for (int i = 0; i < flashcardData.length; i++) {
  //       String docId = "flashcard_${i + 1}";
  //       batch.set(flashcardCollection.doc(docId), flashcardData[i]);
  //     }
  //   }

  //   await batch.commit();
  //   print("SSC Geography flashcards uploaded successfully!");
  // }
  // Function to upload flashcards for CBSE Economics with 'front' and 'back' attributes
  //
// Function to upload flashcards for CBSE Geography with 'front' and 'back' attributes
  // Future<void> uploadGeoFlashcards() async {
  //   String board = "CBSE";
  //   String subject = "Geography";

  //   // Flashcard data mapped to each chapter with front and back attributes
  //   Map<String, List<Map<String, String>>> flashcardData = {
  //     "1": [
  //       {
  //         "front": "What are the three main components of the environment?",
  //         "back": "Natural, Human, and Human-made environments."
  //       },
  //       {
  //         "front": "What is the difference between weather and climate?",
  //         "back":
  //             "Weather is short-term atmospheric conditions; climate is the long-term average of weather."
  //       },
  //       {
  //         "front": "What are the major domains of the Earth?",
  //         "back": "Lithosphere, Atmosphere, Hydrosphere, and Biosphere."
  //       },
  //       {
  //         "front": "What is the importance of the hydrosphere?",
  //         "back":
  //             "It supports marine life, regulates temperature, and provides freshwater."
  //       },
  //       {
  //         "front": "What gases make up the Earth's atmosphere?",
  //         "back":
  //             "Nitrogen (78%), Oxygen (21%), and other gases like Argon, CO2, and Water Vapor."
  //       }
  //     ],
  //     "2": [
  //       {
  //         "front": "What are the major landforms of the Earth?",
  //         "back": "Mountains, Plateaus, and Plains."
  //       },
  //       {
  //         "front": "How are fold mountains formed?",
  //         "back":
  //             "By the collision of tectonic plates, causing the Earth's crust to fold."
  //       },
  //       {
  //         "front": "What is the difference between a plateau and a plain?",
  //         "back":
  //             "A plateau is an elevated flat land, while a plain is a low-lying flat land."
  //       },
  //       {
  //         "front": "What is an earthquake?",
  //         "back":
  //             "A sudden shaking of the Earth's crust due to tectonic movements."
  //       },
  //       {
  //         "front": "Which instrument is used to measure earthquake intensity?",
  //         "back": "The Richter Scale."
  //       }
  //     ],
  //     "3": [
  //       {
  //         "front": "What are the different types of water bodies?",
  //         "back": "Oceans, Seas, Rivers, Lakes, and Groundwater."
  //       },
  //       {
  //         "front": "Which ocean is the largest in the world?",
  //         "back": "The Pacific Ocean."
  //       },
  //       {
  //         "front": "What causes ocean currents?",
  //         "back":
  //             "Wind, Earth's rotation, temperature, and salinity differences."
  //       },
  //       {
  //         "front": "What is the significance of the water cycle?",
  //         "back":
  //             "It maintains Earth's water balance by cycling water through evaporation, condensation, and precipitation."
  //       },
  //       {
  //         "front": "What is groundwater?",
  //         "back": "Water stored beneath the Earth's surface in soil and rocks."
  //       }
  //     ],
  //     "4": [
  //       {
  //         "front":
  //             "What are the factors affecting the distribution of population?",
  //         "back": "Climate, Topography, Soil, Water, and Socioeconomic factors."
  //       },
  //       {
  //         "front":
  //             "What is the difference between population density and population distribution?",
  //         "back":
  //             "Population density is the number of people per unit area, while distribution is how people are spread over an area."
  //       },
  //       {
  //         "front": "Which continent has the highest population?",
  //         "back": "Asia."
  //       },
  //       {
  //         "front": "What is migration?",
  //         "back": "The movement of people from one place to another."
  //       },
  //       {
  //         "front": "What are push and pull factors in migration?",
  //         "back":
  //             "Push factors force people to leave (e.g., war, unemployment), while pull factors attract them (e.g., jobs, better living conditions)."
  //       }
  //     ],
  //     "5": [
  //       {
  //         "front": "What is sustainable development?",
  //         "back":
  //             "Development that meets present needs without compromising future generations."
  //       },
  //       {
  //         "front": "What are renewable and non-renewable resources?",
  //         "back":
  //             "Renewable resources regenerate naturally (e.g., sunlight), while non-renewable ones are finite (e.g., coal)."
  //       },
  //       {
  //         "front": "Why is water conservation important?",
  //         "back":
  //             "To ensure water availability for future generations and prevent shortages."
  //       },
  //       {
  //         "front": "What is deforestation?",
  //         "back": "The large-scale removal of forests for human activities."
  //       },
  //       {
  //         "front": "How can we reduce environmental pollution?",
  //         "back":
  //             "By using renewable energy, reducing waste, planting trees, and promoting sustainable practices."
  //       }
  //     ]
  //   };

  //   WriteBatch batch = _firestore.batch();

  //   // Iterate through each chapter and add flashcards
  //   flashcardData.forEach((chapterId, flashcards) {
  //     CollectionReference flashcardsCollection = _firestore
  //         .collection('boards')
  //         .doc(board)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .collection('flashcards');

  //     for (int i = 0; i < flashcards.length; i++) {
  //       String flashcardId = "flashcard_${i + 1}"; // Naming convention

  //       batch.set(flashcardsCollection.doc(flashcardId), flashcards[i]);
  //     }
  //   });

  //   await batch.commit();
  //   print("✅ Flashcards uploaded successfully for CBSE Geography!");
  // }
// Function to upload flashcards for CBSE History with 'front' and 'back' attributes
  //
// Function to upload flashcards for CBSE Mathematics with 'front' and 'back' attributes
// Function to upload flashcards for CBSE Science with 'front' and 'back' attributes
  // Future<void> uploadSciFlashcards() async {
  //   String board = "CBSE";
  //   String subject = "Science";

  //   // Flashcard data mapped to each chapter with front and back attributes
  //   Map<String, List<Map<String, String>>> flashcardData = {
  //     "1": [
  //       {"front": "What is the chemical formula of water?", "back": "H₂O"},
  //       {
  //         "front": "What gas do plants release during photosynthesis?",
  //         "back": "Oxygen (O₂)"
  //       },
  //       {
  //         "front": "What is the powerhouse of the cell?",
  //         "back": "Mitochondria"
  //       },
  //       {
  //         "front": "Which vitamin is produced in the human body with sunlight?",
  //         "back": "Vitamin D"
  //       },
  //       {"front": "What is the SI unit of force?", "back": "Newton (N)"}
  //     ],
  //     "2": [
  //       {
  //         "front": "What is Newton's First Law of Motion?",
  //         "back":
  //             "An object remains in rest or motion unless acted upon by an external force."
  //       },
  //       {
  //         "front": "What is the speed of light in vacuum?",
  //         "back": "3 × 10⁸ m/s"
  //       },
  //       {
  //         "front": "Which metal is the best conductor of electricity?",
  //         "back": "Silver"
  //       },
  //       {"front": "What is the chemical symbol for Gold?", "back": "Au"},
  //       {
  //         "front":
  //             "Which organ in the human body is responsible for filtering blood?",
  //         "back": "Kidneys"
  //       }
  //     ],
  //     "3": [
  //       {"front": "What is the pH value of pure water?", "back": "7 (Neutral)"},
  //       {
  //         "front": "What type of energy is stored in a stretched rubber band?",
  //         "back": "Potential Energy"
  //       },
  //       {
  //         "front": "What is the main component of Earth's atmosphere?",
  //         "back": "Nitrogen (78%)"
  //       },
  //       {"front": "Which blood cells help in clotting?", "back": "Platelets"},
  //       {
  //         "front": "Which force keeps planets in orbit around the sun?",
  //         "back": "Gravitational Force"
  //       }
  //     ],
  //     "4": [
  //       {
  //         "front": "What is the full form of DNA?",
  //         "back": "Deoxyribonucleic Acid"
  //       },
  //       {"front": "What is the atomic number of Carbon?", "back": "6"},
  //       {
  //         "front": "Which acid is found in lemon and orange?",
  //         "back": "Citric Acid"
  //       },
  //       {
  //         "front": "What is the boiling point of water at sea level?",
  //         "back": "100°C (212°F)"
  //       },
  //       {
  //         "front": "Which gas is used in balloons to make them float?",
  //         "back": "Helium (He)"
  //       }
  //     ],
  //     "5": [
  //       {"front": "What is the name of our galaxy?", "back": "Milky Way"},
  //       {
  //         "front":
  //             "Which organelle in a plant cell is responsible for photosynthesis?",
  //         "back": "Chloroplast"
  //       },
  //       {
  //         "front": "Which element is necessary for breathing and survival?",
  //         "back": "Oxygen"
  //       },
  //       {
  //         "front": "What is the hardest natural substance on Earth?",
  //         "back": "Diamond"
  //       },
  //       {
  //         "front": "What is the scientific name of the human species?",
  //         "back": "Homo sapiens"
  //       }
  //     ]
  //   };

  //   WriteBatch batch = _firestore.batch();

  //   // Iterate through each chapter and add flashcards
  //   flashcardData.forEach((chapterId, flashcards) {
  //     CollectionReference flashcardsCollection = _firestore
  //         .collection('boards')
  //         .doc(board)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .collection('flashcards');

  //     for (int i = 0; i < flashcards.length; i++) {
  //       String flashcardId = "flashcard_${i + 1}"; // Naming convention

  //       batch.set(flashcardsCollection.doc(flashcardId), flashcards[i]);
  //     }
  //   });

  //   await batch.commit();
  //   print("✅ Flashcards uploaded successfully for CBSE Science!");
  // }
  // Future<void> uploadCBSEEconomicsQuiz() async {
  //   String board = "CBSE";
  //   String subject = "Economics";

  //   // Quiz data mapped to each chapter with question, options, and correct answer
  //   Map<String, List<Map<String, dynamic>>> quizData = {
  //     "1": [
  //       {
  //         "question": "What is the primary sector of the economy?",
  //         "option1": "Agriculture",
  //         "option2": "Manufacturing",
  //         "option3": "Banking",
  //         "option4": "IT Services",
  //         "correct_answer": "Agriculture"
  //       },
  //       {
  //         "question": "Which organization calculates India's GDP?",
  //         "option1": "IMF",
  //         "option2": "World Bank",
  //         "option3": "CSO",
  //         "option4": "WTO",
  //         "correct_answer": "CSO"
  //       },
  //       {
  //         "question": "What does GDP stand for?",
  //         "option1": "Gross Domestic Production",
  //         "option2": "Gross Development Product",
  //         "option3": "Gross Domestic Product",
  //         "option4": "General Domestic Production",
  //         "correct_answer": "Gross Domestic Product"
  //       },
  //       {
  //         "question": "Which sector includes IT and banking services?",
  //         "option1": "Primary",
  //         "option2": "Secondary",
  //         "option3": "Tertiary",
  //         "option4": "Agricultural",
  //         "correct_answer": "Tertiary"
  //       },
  //       {
  //         "question": "Which sector includes manufacturing industries?",
  //         "option1": "Primary",
  //         "option2": "Secondary",
  //         "option3": "Tertiary",
  //         "option4": "Quaternary",
  //         "correct_answer": "Secondary"
  //       },
  //       {
  //         "question": "What is the full form of WTO?",
  //         "option1": "World Trade Organization",
  //         "option2": "World Transport Organization",
  //         "option3": "World Technology Organization",
  //         "option4": "World Tourism Organization",
  //         "correct_answer": "World Trade Organization"
  //       },
  //       {
  //         "question": "Which country has the largest GDP in the world?",
  //         "option1": "India",
  //         "option2": "China",
  //         "option3": "USA",
  //         "option4": "Japan",
  //         "correct_answer": "USA"
  //       },
  //       {
  //         "question": "Which of the following is NOT a factor of production?",
  //         "option1": "Land",
  //         "option2": "Labour",
  //         "option3": "Capital",
  //         "option4": "Technology",
  //         "correct_answer": "Technology"
  //       },
  //       {
  //         "question": "Which Indian agency is responsible for monetary policy?",
  //         "option1": "SEBI",
  //         "option2": "RBI",
  //         "option3": "Finance Ministry",
  //         "option4": "IMF",
  //         "correct_answer": "RBI"
  //       },
  //       {
  //         "question": "What is India's main source of revenue?",
  //         "option1": "Income Tax",
  //         "option2": "Corporate Tax",
  //         "option3": "GST",
  //         "option4": "Customs Duty",
  //         "correct_answer": "GST"
  //       }
  //     ],
  //     "2": [
  //       {
  //         "question": "What is demand in economics?",
  //         "option1": "The supply of goods",
  //         "option2": "The desire to own a product",
  //         "option3": "The need for survival",
  //         "option4": "The cost of production",
  //         "correct_answer": "The desire to own a product"
  //       },
  //       {
  //         "question": "What is the law of supply?",
  //         "option1": "Higher price leads to higher supply",
  //         "option2": "Lower price increases supply",
  //         "option3": "Demand is always equal to supply",
  //         "option4": "Supply is fixed regardless of price",
  //         "correct_answer": "Higher price leads to higher supply"
  //       },
  //       {
  //         "question": "Which factor affects demand the most?",
  //         "option1": "Consumer income",
  //         "option2": "Government policy",
  //         "option3": "Number of producers",
  //         "option4": "Technology",
  //         "correct_answer": "Consumer income"
  //       },
  //       {
  //         "question": "What is the price elasticity of demand?",
  //         "option1": "A measure of demand response to price change",
  //         "option2": "The relationship between price and supply",
  //         "option3": "The ability to control market prices",
  //         "option4": "The total production cost",
  //         "correct_answer": "A measure of demand response to price change"
  //       },
  //       {
  //         "question": "What is equilibrium price?",
  //         "option1": "The price at which supply equals demand",
  //         "option2": "The highest possible price",
  //         "option3": "The price controlled by the government",
  //         "option4": "The cost of production",
  //         "correct_answer": "The price at which supply equals demand"
  //       },
  //       {
  //         "question": "What is a monopoly?",
  //         "option1": "Market with only one seller",
  //         "option2": "Market with many competitors",
  //         "option3": "Market controlled by government",
  //         "option4": "A free market economy",
  //         "correct_answer": "Market with only one seller"
  //       },
  //       {
  //         "question": "Which is an example of a public good?",
  //         "option1": "Clothing",
  //         "option2": "Electricity",
  //         "option3": "Street lighting",
  //         "option4": "Mobile phones",
  //         "correct_answer": "Street lighting"
  //       },
  //       {
  //         "question": "Which tax is considered progressive?",
  //         "option1": "Income tax",
  //         "option2": "Sales tax",
  //         "option3": "Excise duty",
  //         "option4": "GST",
  //         "correct_answer": "Income tax"
  //       },
  //       {
  //         "question": "What does inflation measure?",
  //         "option1": "Rise in the general price level",
  //         "option2": "Increase in GDP",
  //         "option3": "Decline in unemployment",
  //         "option4": "Growth in exports",
  //         "correct_answer": "Rise in the general price level"
  //       },
  //       {
  //         "question": "What is an example of direct tax?",
  //         "option1": "Sales tax",
  //         "option2": "Income tax",
  //         "option3": "GST",
  //         "option4": "Customs duty",
  //         "correct_answer": "Income tax"
  //       }
  //     ],
  //     "3": [
  //       {
  //         "question": "What is the primary objective of economic planning?",
  //         "option1": "Maximizing profits",
  //         "option2": "Achieving economic growth",
  //         "option3": "Increasing taxes",
  //         "option4": "Reducing exports",
  //         "correct_answer": "Achieving economic growth"
  //       },
  //       {
  //         "question": "What is the full form of GDP?",
  //         "option1": "Gross Domestic Product",
  //         "option2": "General Domestic Production",
  //         "option3": "Gross Development Plan",
  //         "option4": "Global Domestic Policy",
  //         "correct_answer": "Gross Domestic Product"
  //       },
  //       {
  //         "question": "Which sector contributes the most to India's GDP?",
  //         "option1": "Agriculture",
  //         "option2": "Manufacturing",
  //         "option3": "Tertiary (Services)",
  //         "option4": "Mining",
  //         "correct_answer": "Tertiary (Services)"
  //       },
  //       {
  //         "question": "What is the role of RBI in India's economy?",
  //         "option1": "To collect taxes",
  //         "option2": "To regulate the banking system",
  //         "option3": "To construct roads",
  //         "option4": "To issue passports",
  //         "correct_answer": "To regulate the banking system"
  //       },
  //       {
  //         "question":
  //             "Which indicator is used to measure economic development?",
  //         "option1": "Inflation Rate",
  //         "option2": "GDP Growth Rate",
  //         "option3": "Population Growth Rate",
  //         "option4": "Exchange Rate",
  //         "correct_answer": "GDP Growth Rate"
  //       },
  //       {
  //         "question": "What does fiscal policy deal with?",
  //         "option1": "Taxation and government spending",
  //         "option2": "Money supply",
  //         "option3": "Foreign trade",
  //         "option4": "Stock market regulations",
  //         "correct_answer": "Taxation and government spending"
  //       },
  //       {
  //         "question": "Which body prepares India's Five-Year Plans?",
  //         "option1": "Ministry of Finance",
  //         "option2": "Reserve Bank of India",
  //         "option3": "NITI Aayog",
  //         "option4": "IMF",
  //         "correct_answer": "NITI Aayog"
  //       },
  //       {
  //         "question": "What is the meaning of 'Per Capita Income'?",
  //         "option1": "Total income of the government",
  //         "option2": "Average income per person in a country",
  //         "option3": "Income earned by the richest 10% of people",
  //         "option4": "Total exports and imports of a country",
  //         "correct_answer": "Average income per person in a country"
  //       },
  //       {
  //         "question": "What is the primary function of a commercial bank?",
  //         "option1": "Printing money",
  //         "option2": "Collecting taxes",
  //         "option3": "Providing loans and accepting deposits",
  //         "option4": "Managing government funds",
  //         "correct_answer": "Providing loans and accepting deposits"
  //       },
  //       {
  //         "question": "What does inflation refer to?",
  //         "option1": "Decrease in prices",
  //         "option2": "Increase in the general price level",
  //         "option3": "Increase in exports",
  //         "option4": "Reduction in GDP",
  //         "correct_answer": "Increase in the general price level"
  //       }
  //     ],
  //     "4": [
  //       {
  //         "question":
  //             "What is the primary objective of poverty alleviation programs?",
  //         "option1": "To increase government revenue",
  //         "option2": "To reduce income inequality and improve living standards",
  //         "option3": "To promote industrialization",
  //         "option4": "To control population growth",
  //         "correct_answer":
  //             "To reduce income inequality and improve living standards"
  //       },
  //       {
  //         "question":
  //             "Which organization in India calculates the poverty line?",
  //         "option1": "NITI Aayog",
  //         "option2": "Planning Commission",
  //         "option3": "National Sample Survey Office (NSSO)",
  //         "option4": "Ministry of Finance",
  //         "correct_answer": "National Sample Survey Office (NSSO)"
  //       },
  //       {
  //         "question": "Which is NOT a measure of poverty?",
  //         "option1": "Income level",
  //         "option2": "Nutrition intake",
  //         "option3": "Employment opportunities",
  //         "option4": "Stock market performance",
  //         "correct_answer": "Stock market performance"
  //       },
  //       {
  //         "question": "What is the major cause of rural poverty in India?",
  //         "option1": "High literacy rate",
  //         "option2": "Unemployment and lack of infrastructure",
  //         "option3": "Overproduction of crops",
  //         "option4": "Excessive industrialization",
  //         "correct_answer": "Unemployment and lack of infrastructure"
  //       },
  //       {
  //         "question": "What does MGNREGA stand for?",
  //         "option1": "Mahatma Gandhi National Rural Employment Guarantee Act",
  //         "option2": "Modern Government National Resource Economic Growth Act",
  //         "option3":
  //             "Monetary Growth and National Reserve Expansion Guidelines Act",
  //         "option4": "Ministry of Growth and New Economic Governance Act",
  //         "correct_answer":
  //             "Mahatma Gandhi National Rural Employment Guarantee Act"
  //       },
  //       {
  //         "question":
  //             "Which sector employs the largest number of poor people in India?",
  //         "option1": "Agriculture",
  //         "option2": "Banking",
  //         "option3": "IT Industry",
  //         "option4": "Tourism",
  //         "correct_answer": "Agriculture"
  //       },
  //       {
  //         "question":
  //             "Which is a government initiative for food security in India?",
  //         "option1": "Green Revolution",
  //         "option2": "Mid-Day Meal Scheme",
  //         "option3": "Digital India",
  //         "option4": "Make in India",
  //         "correct_answer": "Mid-Day Meal Scheme"
  //       },
  //       {
  //         "question": "Which Indian state has the highest poverty rate?",
  //         "option1": "Kerala",
  //         "option2": "Bihar",
  //         "option3": "Punjab",
  //         "option4": "Gujarat",
  //         "correct_answer": "Bihar"
  //       },
  //       {
  //         "question":
  //             "Which measure is used to classify people below the poverty line?",
  //         "option1": "Monthly salary above ₹50,000",
  //         "option2": "Caloric intake and income levels",
  //         "option3": "Number of cars owned",
  //         "option4": "Credit score",
  //         "correct_answer": "Caloric intake and income levels"
  //       },
  //       {
  //         "question": "Which program aims at skill development for the poor?",
  //         "option1": "Pradhan Mantri Jan Dhan Yojana",
  //         "option2": "Deen Dayal Upadhyaya Grameen Kaushalya Yojana (DDU-GKY)",
  //         "option3": "Smart Cities Mission",
  //         "option4": "Startup India",
  //         "correct_answer":
  //             "Deen Dayal Upadhyaya Grameen Kaushalya Yojana (DDU-GKY)"
  //       }
  //     ],
  //     "5": [
  //       {
  //         "question": "What is sustainable development?",
  //         "option1":
  //             "Development that meets present needs without compromising future generations",
  //         "option2":
  //             "Rapid industrialization without any environmental concerns",
  //         "option3": "Economic growth at any cost",
  //         "option4": "Short-term economic policies for immediate benefits",
  //         "correct_answer":
  //             "Development that meets present needs without compromising future generations"
  //       },
  //       {
  //         "question": "Which of the following is a renewable resource?",
  //         "option1": "Coal",
  //         "option2": "Petroleum",
  //         "option3": "Solar Energy",
  //         "option4": "Natural Gas",
  //         "correct_answer": "Solar Energy"
  //       },
  //       {
  //         "question": "Which sector is the largest consumer of water in India?",
  //         "option1": "Agriculture",
  //         "option2": "Industry",
  //         "option3": "Domestic households",
  //         "option4": "Transport",
  //         "correct_answer": "Agriculture"
  //       },
  //       {
  //         "question":
  //             "Which of the following is an example of sustainable agricultural practice?",
  //         "option1": "Excessive use of chemical fertilizers",
  //         "option2": "Crop rotation and organic farming",
  //         "option3": "Deforestation for farmland expansion",
  //         "option4": "Mono-cropping",
  //         "correct_answer": "Crop rotation and organic farming"
  //       },
  //       {
  //         "question": "What is the main cause of deforestation?",
  //         "option1": "Increasing forest cover",
  //         "option2": "Sustainable farming",
  //         "option3": "Clearing land for agriculture and urbanization",
  //         "option4": "Reforestation efforts",
  //         "correct_answer": "Clearing land for agriculture and urbanization"
  //       },
  //       {
  //         "question":
  //             "Which of the following is NOT an effect of air pollution?",
  //         "option1": "Respiratory diseases",
  //         "option2": "Ozone layer depletion",
  //         "option3": "Improved agricultural productivity",
  //         "option4": "Global warming",
  //         "correct_answer": "Improved agricultural productivity"
  //       },
  //       {
  //         "question": "What does GDP stand for?",
  //         "option1": "Gross Domestic Product",
  //         "option2": "Global Development Plan",
  //         "option3": "Gross Departmental Production",
  //         "option4": "General Domestic Policy",
  //         "correct_answer": "Gross Domestic Product"
  //       },
  //       {
  //         "question":
  //             "Which energy source is the most environmentally friendly?",
  //         "option1": "Coal",
  //         "option2": "Petrol",
  //         "option3": "Wind energy",
  //         "option4": "Diesel",
  //         "correct_answer": "Wind energy"
  //       },
  //       {
  //         "question": "What is the major cause of water pollution in India?",
  //         "option1": "Natural rainwater",
  //         "option2": "Industrial waste and untreated sewage",
  //         "option3": "Water conservation projects",
  //         "option4": "Cloud seeding",
  //         "correct_answer": "Industrial waste and untreated sewage"
  //       },
  //       {
  //         "question":
  //             "Which of the following is a step towards sustainable development?",
  //         "option1": "Exploiting natural resources without control",
  //         "option2": "Reducing, reusing, and recycling resources",
  //         "option3": "Ignoring climate change",
  //         "option4": "Overuse of fossil fuels",
  //         "correct_answer": "Reducing, reusing, and recycling resources"
  //       }
  //     ],
  //   };

  //   WriteBatch batch = _firestore.batch();

  //   // Iterate through each chapter and add quiz questions
  //   quizData.forEach((chapterId, quizQuestions) {
  //     CollectionReference quizCollection = _firestore
  //         .collection('boards')
  //         .doc(board)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .collection('quiz');

  //     for (int i = 0; i < quizQuestions.length; i++) {
  //       String quizId = "quiz_${i + 1}"; // Naming convention

  //       batch.set(quizCollection.doc(quizId), quizQuestions[i]);
  //     }
  //   });

  //   await batch.commit();
  //   print("✅ Quiz questions uploaded successfully for CBSE Economics!");
  // }
  // Future<void> uploadCBSEGeographyQuiz() async {
  //   String board = "CBSE";
  //   String subject = "Geography";

  //   // Quiz data for all 5 chapters
  //   Map<String, List<Map<String, dynamic>>> quizData = {
  //     "1": [
  //       {
  //         "question": "What is the shape of the Earth?",
  //         "option1": "Perfectly spherical",
  //         "option2": "Flat",
  //         "option3": "Oblate spheroid",
  //         "option4": "Cylindrical",
  //         "correct_answer": "Oblate spheroid"
  //       },
  //       {
  //         "question":
  //             "Which line divides the Earth into Northern and Southern Hemispheres?",
  //         "option1": "Tropic of Cancer",
  //         "option2": "Tropic of Capricorn",
  //         "option3": "Equator",
  //         "option4": "Prime Meridian",
  //         "correct_answer": "Equator"
  //       },
  //       {
  //         "question": "What causes day and night?",
  //         "option1": "Revolution of Earth",
  //         "option2": "Rotation of Earth",
  //         "option3": "Movement of Sun",
  //         "option4": "Gravitational pull",
  //         "correct_answer": "Rotation of Earth"
  //       },
  //       {
  //         "question": "Which planet is known as Earth's twin?",
  //         "option1": "Mars",
  //         "option2": "Venus",
  //         "option3": "Jupiter",
  //         "option4": "Mercury",
  //         "correct_answer": "Venus"
  //       },
  //       {
  //         "question": "Which is the longest latitude?",
  //         "option1": "Equator",
  //         "option2": "Tropic of Cancer",
  //         "option3": "Tropic of Capricorn",
  //         "option4": "Arctic Circle",
  //         "correct_answer": "Equator"
  //       },
  //       {
  //         "question": "Which gas is most abundant in Earth's atmosphere?",
  //         "option1": "Oxygen",
  //         "option2": "Nitrogen",
  //         "option3": "Carbon Dioxide",
  //         "option4": "Helium",
  //         "correct_answer": "Nitrogen"
  //       },
  //       {
  //         "question": "What is the main source of energy for Earth?",
  //         "option1": "Wind",
  //         "option2": "The Moon",
  //         "option3": "The Sun",
  //         "option4": "Volcanoes",
  //         "correct_answer": "The Sun"
  //       },
  //       {
  //         "question": "Which is the largest ocean on Earth?",
  //         "option1": "Atlantic Ocean",
  //         "option2": "Indian Ocean",
  //         "option3": "Pacific Ocean",
  //         "option4": "Arctic Ocean",
  //         "correct_answer": "Pacific Ocean"
  //       },
  //       {
  //         "question":
  //             "What is the imaginary line running from the North Pole to the South Pole?",
  //         "option1": "Equator",
  //         "option2": "Prime Meridian",
  //         "option3": "Tropic of Cancer",
  //         "option4": "Tropic of Capricorn",
  //         "correct_answer": "Prime Meridian"
  //       },
  //       {
  //         "question": "Which continent has the largest land area?",
  //         "option1": "Africa",
  //         "option2": "North America",
  //         "option3": "Asia",
  //         "option4": "Europe",
  //         "correct_answer": "Asia"
  //       }
  //     ],
  //     "2": [
  //       {
  //         "question": "What is the process of breaking down rocks called?",
  //         "option1": "Erosion",
  //         "option2": "Weathering",
  //         "option3": "Sedimentation",
  //         "option4": "Deposition",
  //         "correct_answer": "Weathering"
  //       },
  //       {
  //         "question": "Which is the hardest natural substance on Earth?",
  //         "option1": "Granite",
  //         "option2": "Diamond",
  //         "option3": "Quartz",
  //         "option4": "Gold",
  //         "correct_answer": "Diamond"
  //       },
  //       {
  //         "question": "What is the main cause of earthquakes?",
  //         "option1": "Volcanic eruption",
  //         "option2": "Tectonic plate movements",
  //         "option3": "Wind pressure",
  //         "option4": "Heavy rainfall",
  //         "correct_answer": "Tectonic plate movements"
  //       },
  //       {
  //         "question": "Which layer of the Earth is the hottest?",
  //         "option1": "Crust",
  //         "option2": "Mantle",
  //         "option3": "Outer Core",
  //         "option4": "Inner Core",
  //         "correct_answer": "Inner Core"
  //       },
  //       {
  //         "question": "What is the uppermost layer of Earth called?",
  //         "option1": "Crust",
  //         "option2": "Mantle",
  //         "option3": "Core",
  //         "option4": "Lithosphere",
  //         "correct_answer": "Crust"
  //       },
  //       {
  //         "question": "Which landform is created by river erosion?",
  //         "option1": "Valley",
  //         "option2": "Plateau",
  //         "option3": "Desert",
  //         "option4": "Coastline",
  //         "correct_answer": "Valley"
  //       },
  //       {
  //         "question": "Which type of rock is formed from lava?",
  //         "option1": "Igneous",
  //         "option2": "Sedimentary",
  //         "option3": "Metamorphic",
  //         "option4": "Limestone",
  //         "correct_answer": "Igneous"
  //       },
  //       {
  //         "question": "Which is the largest desert in the world?",
  //         "option1": "Sahara",
  //         "option2": "Thar",
  //         "option3": "Gobi",
  //         "option4": "Kalahari",
  //         "correct_answer": "Sahara"
  //       },
  //       {
  //         "question": "Which process moves sand and pebbles along a coastline?",
  //         "option1": "Deforestation",
  //         "option2": "Longshore drift",
  //         "option3": "Precipitation",
  //         "option4": "Condensation",
  //         "correct_answer": "Longshore drift"
  //       },
  //       {
  //         "question": "What is the deepest ocean trench in the world?",
  //         "option1": "Mariana Trench",
  //         "option2": "Java Trench",
  //         "option3": "Puerto Rico Trench",
  //         "option4": "Tonga Trench",
  //         "correct_answer": "Mariana Trench"
  //       }
  //     ],
  //     "3": [
  //       {
  //         "question": "What is the largest ocean on Earth?",
  //         "option1": "Atlantic Ocean",
  //         "option2": "Indian Ocean",
  //         "option3": "Pacific Ocean",
  //         "option4": "Arctic Ocean",
  //         "correct_answer": "Pacific Ocean"
  //       },
  //       {
  //         "question": "Which ocean current is the strongest and warmest?",
  //         "option1": "Gulf Stream",
  //         "option2": "Humboldt Current",
  //         "option3": "Labrador Current",
  //         "option4": "California Current",
  //         "correct_answer": "Gulf Stream"
  //       },
  //       {
  //         "question":
  //             "Which process causes ocean water to turn into water vapor?",
  //         "option1": "Condensation",
  //         "option2": "Evaporation",
  //         "option3": "Precipitation",
  //         "option4": "Infiltration",
  //         "correct_answer": "Evaporation"
  //       },
  //       {
  //         "question":
  //             "Which type of water body is completely surrounded by land?",
  //         "option1": "Lake",
  //         "option2": "Ocean",
  //         "option3": "Gulf",
  //         "option4": "Bay",
  //         "correct_answer": "Lake"
  //       },
  //       {
  //         "question": "What is the longest river in the world?",
  //         "option1": "Amazon River",
  //         "option2": "Nile River",
  //         "option3": "Yangtze River",
  //         "option4": "Mississippi River",
  //         "correct_answer": "Nile River"
  //       },
  //       {
  //         "question":
  //             "Which ocean current affects the climate of Western Europe?",
  //         "option1": "Humboldt Current",
  //         "option2": "Gulf Stream",
  //         "option3": "Canary Current",
  //         "option4": "Benguela Current",
  //         "correct_answer": "Gulf Stream"
  //       },
  //       {
  //         "question": "Which water body separates India and Sri Lanka?",
  //         "option1": "Bay of Bengal",
  //         "option2": "Arabian Sea",
  //         "option3": "Palk Strait",
  //         "option4": "Gulf of Mexico",
  //         "correct_answer": "Palk Strait"
  //       },
  //       {
  //         "question": "What is the deepest ocean trench in the world?",
  //         "option1": "Puerto Rico Trench",
  //         "option2": "Tonga Trench",
  //         "option3": "Mariana Trench",
  //         "option4": "Java Trench",
  //         "correct_answer": "Mariana Trench"
  //       },
  //       {
  //         "question": "Which of the following is a cold ocean current?",
  //         "option1": "Kuroshio Current",
  //         "option2": "Agulhas Current",
  //         "option3": "Benguela Current",
  //         "option4": "North Atlantic Drift",
  //         "correct_answer": "Benguela Current"
  //       },
  //       {
  //         "question": "What percentage of Earth's surface is covered by water?",
  //         "option1": "50%",
  //         "option2": "60%",
  //         "option3": "70%",
  //         "option4": "80%",
  //         "correct_answer": "70%"
  //       }
  //     ],
  //     "4": [
  //       {
  //         "question": "What is the main factor that influences climate?",
  //         "option1": "Population",
  //         "option2": "Latitude",
  //         "option3": "Culture",
  //         "option4": "Economy",
  //         "correct_answer": "Latitude"
  //       },
  //       {
  //         "question": "Which layer of the atmosphere contains the ozone layer?",
  //         "option1": "Troposphere",
  //         "option2": "Stratosphere",
  //         "option3": "Mesosphere",
  //         "option4": "Exosphere",
  //         "correct_answer": "Stratosphere"
  //       },
  //       {
  //         "question":
  //             "What is the term for the day-to-day conditions of the atmosphere?",
  //         "option1": "Climate",
  //         "option2": "Seasons",
  //         "option3": "Weather",
  //         "option4": "Temperature",
  //         "correct_answer": "Weather"
  //       },
  //       {
  //         "question": "Which of the following is a greenhouse gas?",
  //         "option1": "Oxygen",
  //         "option2": "Nitrogen",
  //         "option3": "Carbon Dioxide",
  //         "option4": "Neon",
  //         "correct_answer": "Carbon Dioxide"
  //       },
  //       {
  //         "question":
  //             "Which instrument is used to measure atmospheric pressure?",
  //         "option1": "Thermometer",
  //         "option2": "Barometer",
  //         "option3": "Anemometer",
  //         "option4": "Hygrometer",
  //         "correct_answer": "Barometer"
  //       },
  //       {
  //         "question":
  //             "Which climate zone is characterized by heavy rainfall and high temperatures?",
  //         "option1": "Polar",
  //         "option2": "Temperate",
  //         "option3": "Tropical",
  //         "option4": "Arid",
  //         "correct_answer": "Tropical"
  //       },
  //       {
  //         "question": "What is El Niño?",
  //         "option1": "A type of cyclone",
  //         "option2": "A warm ocean current",
  //         "option3": "A wind pattern",
  //         "option4": "A desert phenomenon",
  //         "correct_answer": "A warm ocean current"
  //       },
  //       {
  //         "question": "Which wind system brings monsoon rains to India?",
  //         "option1": "Westerlies",
  //         "option2": "Trade Winds",
  //         "option3": "Jet Streams",
  //         "option4": "Southwest Monsoon Winds",
  //         "correct_answer": "Southwest Monsoon Winds"
  //       },
  //       {
  //         "question":
  //             "What type of rainfall occurs when warm, moist air rises over mountains?",
  //         "option1": "Cyclonic rainfall",
  //         "option2": "Orographic rainfall",
  //         "option3": "Convectional rainfall",
  //         "option4": "Frontal rainfall",
  //         "correct_answer": "Orographic rainfall"
  //       },
  //       {
  //         "question":
  //             "Which desert experiences extreme temperature differences between day and night?",
  //         "option1": "Sahara Desert",
  //         "option2": "Thar Desert",
  //         "option3": "Atacama Desert",
  //         "option4": "Gobi Desert",
  //         "correct_answer": "Gobi Desert"
  //       }
  //     ],
  //     "5": [
  //       {
  //         "question": "What is the primary cause of earthquakes?",
  //         "option1": "Volcanic eruptions",
  //         "option2": "Tectonic plate movements",
  //         "option3": "Tsunamis",
  //         "option4": "Heavy rainfall",
  //         "correct_answer": "Tectonic plate movements"
  //       },
  //       {
  //         "question":
  //             "Which scale is used to measure the magnitude of earthquakes?",
  //         "option1": "Richter Scale",
  //         "option2": "Beaufort Scale",
  //         "option3": "Fahrenheit Scale",
  //         "option4": "Seismic Scale",
  //         "correct_answer": "Richter Scale"
  //       },
  //       {
  //         "question":
  //             "Which natural disaster is caused by underwater earthquakes?",
  //         "option1": "Cyclone",
  //         "option2": "Tsunami",
  //         "option3": "Landslide",
  //         "option4": "Drought",
  //         "correct_answer": "Tsunami"
  //       },
  //       {
  //         "question":
  //             "What is the name of a rotating storm over warm ocean waters?",
  //         "option1": "Cyclone",
  //         "option2": "Tornado",
  //         "option3": "Blizzard",
  //         "option4": "Hurricane",
  //         "correct_answer": "Cyclone"
  //       },
  //       {
  //         "question": "Which of the following is NOT a geological disaster?",
  //         "option1": "Earthquake",
  //         "option2": "Flood",
  //         "option3": "Volcanic eruption",
  //         "option4": "Landslide",
  //         "correct_answer": "Flood"
  //       },
  //       {
  //         "question": "What is the primary cause of floods?",
  //         "option1": "Deforestation",
  //         "option2": "Heavy rainfall",
  //         "option3": "Global warming",
  //         "option4": "Earthquake",
  //         "correct_answer": "Heavy rainfall"
  //       },
  //       {
  //         "question": "Which agency in India monitors earthquakes?",
  //         "option1": "Indian Meteorological Department (IMD)",
  //         "option2": "National Highway Authority of India (NHAI)",
  //         "option3": "Reserve Bank of India (RBI)",
  //         "option4": "Election Commission",
  //         "correct_answer": "Indian Meteorological Department (IMD)"
  //       },
  //       {
  //         "question": "Which of these is a human-made hazard?",
  //         "option1": "Landslide",
  //         "option2": "Deforestation",
  //         "option3": "Tsunami",
  //         "option4": "Volcanic eruption",
  //         "correct_answer": "Deforestation"
  //       },
  //       {
  //         "question": "What should you do during an earthquake?",
  //         "option1": "Run outside immediately",
  //         "option2": "Stay indoors and take cover under sturdy furniture",
  //         "option3": "Stand near glass windows",
  //         "option4": "Use elevators to escape",
  //         "correct_answer": "Stay indoors and take cover under sturdy furniture"
  //       },
  //       {
  //         "question": "Which type of volcano has erupted recently?",
  //         "option1": "Dormant volcano",
  //         "option2": "Active volcano",
  //         "option3": "Extinct volcano",
  //         "option4": "Shield volcano",
  //         "correct_answer": "Active volcano"
  //       }
  //     ]
  //   };

  //   WriteBatch batch = FirebaseFirestore.instance.batch();

  //   quizData.forEach((chapterId, questions) {
  //     CollectionReference quizCollection = FirebaseFirestore.instance
  //         .collection('boards')
  //         .doc(board)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .collection('quiz');

  //     for (int i = 0; i < questions.length; i++) {
  //       String quizId = "quiz_${i + 1}"; // Naming convention

  //       batch.set(quizCollection.doc(quizId), questions[i]);
  //     }
  //   });

  //   await batch.commit();
  //   print("✅ Quiz questions uploaded successfully for CBSE Geography!");
  // }
  // Future<void> uploadCBSEHistoryQuiz() async {
  //   String board = "CBSE";
  //   String subject = "History";

  //   // Quiz data for each chapter
  //   Map<String, List<Map<String, dynamic>>> quizData = {
  //     "1": [
  //       // Chapter 1: The Rise of Nationalism in Europe
  //       {
  //         "question":
  //             "Who is known as the architect of the unification of Germany?",
  //         "option1": "Giuseppe Mazzini",
  //         "option2": "Otto von Bismarck",
  //         "option3": "Napoleon Bonaparte",
  //         "option4": "Count Cavour",
  //         "correct_answer": "Otto von Bismarck"
  //       },
  //       {
  //         "question": "Which treaty ended the Napoleonic Wars?",
  //         "option1": "Treaty of Versailles",
  //         "option2": "Treaty of Vienna",
  //         "option3": "Treaty of Paris",
  //         "option4": "Treaty of Tordesillas",
  //         "correct_answer": "Treaty of Vienna"
  //       },
  //       {
  //         "question": "Which country led the process of Italian unification?",
  //         "option1": "Germany",
  //         "option2": "France",
  //         "option3": "Prussia",
  //         "option4": "Piedmont-Sardinia",
  //         "correct_answer": "Piedmont-Sardinia"
  //       },
  //       {
  //         "question": "What was the main goal of the French Revolution?",
  //         "option1": "Expansion of territory",
  //         "option2": "Unification of Italy",
  //         "option3": "End of monarchy and establishment of a republic",
  //         "option4": "Industrialization",
  //         "correct_answer": "End of monarchy and establishment of a republic"
  //       },
  //       {
  //         "question":
  //             "Which ideology emphasizes pride in one's nation and culture?",
  //         "option1": "Communism",
  //         "option2": "Capitalism",
  //         "option3": "Nationalism",
  //         "option4": "Imperialism",
  //         "correct_answer": "Nationalism"
  //       },
  //       {
  //         "question": "Who wrote ‘The Spirit of the Laws’?",
  //         "option1": "Montesquieu",
  //         "option2": "Voltaire",
  //         "option3": "Rousseau",
  //         "option4": "Karl Marx",
  //         "correct_answer": "Montesquieu"
  //       },
  //       {
  //         "question": "Which event marked the end of Napoleon’s rule?",
  //         "option1": "Battle of Waterloo",
  //         "option2": "French Revolution",
  //         "option3": "Battle of Leipzig",
  //         "option4": "American Revolution",
  //         "correct_answer": "Battle of Waterloo"
  //       },
  //       {
  //         "question":
  //             "Which empire dominated Eastern Europe before World War I?",
  //         "option1": "French Empire",
  //         "option2": "British Empire",
  //         "option3": "Austro-Hungarian Empire",
  //         "option4": "Ottoman Empire",
  //         "correct_answer": "Austro-Hungarian Empire"
  //       },
  //       {
  //         "question": "Who played a crucial role in the unification of Italy?",
  //         "option1": "Louis XVI",
  //         "option2": "Garibaldi",
  //         "option3": "Robespierre",
  //         "option4": "Lenin",
  //         "correct_answer": "Garibaldi"
  //       },
  //       {
  //         "question":
  //             "Which revolution inspired many nationalist movements in Europe?",
  //         "option1": "Russian Revolution",
  //         "option2": "Industrial Revolution",
  //         "option3": "French Revolution",
  //         "option4": "Scientific Revolution",
  //         "correct_answer": "French Revolution"
  //       }
  //     ],
  //     "2": [
  //       // Chapter 2: The Nationalist Movement in India
  //       {
  //         "question":
  //             "Who was the first President of the Indian National Congress?",
  //         "option1": "Mahatma Gandhi",
  //         "option2": "Jawaharlal Nehru",
  //         "option3": "W.C. Banerjee",
  //         "option4": "Sardar Patel",
  //         "correct_answer": "W.C. Banerjee"
  //       },
  //       {
  //         "question":
  //             "Which movement was started by Gandhi after the Jallianwala Bagh massacre?",
  //         "option1": "Non-Cooperation Movement",
  //         "option2": "Quit India Movement",
  //         "option3": "Civil Disobedience Movement",
  //         "option4": "Swadeshi Movement",
  //         "correct_answer": "Non-Cooperation Movement"
  //       },
  //       {
  //         "question": "Who gave the slogan 'Do or Die'?",
  //         "option1": "Subhash Chandra Bose",
  //         "option2": "Mahatma Gandhi",
  //         "option3": "Bhagat Singh",
  //         "option4": "Sardar Patel",
  //         "correct_answer": "Mahatma Gandhi"
  //       },
  //       {
  //         "question":
  //             "Which event led to the withdrawal of the Non-Cooperation Movement?",
  //         "option1": "Chauri Chaura incident",
  //         "option2": "Salt March",
  //         "option3": "Jallianwala Bagh massacre",
  //         "option4": "Partition of Bengal",
  //         "correct_answer": "Chauri Chaura incident"
  //       },
  //       {
  //         "question":
  //             "Which movement was launched in 1930 to break the salt law?",
  //         "option1": "Khilafat Movement",
  //         "option2": "Civil Disobedience Movement",
  //         "option3": "Swadeshi Movement",
  //         "option4": "Quit India Movement",
  //         "correct_answer": "Civil Disobedience Movement"
  //       },
  //       {
  //         "question": "When was the Quit India Movement launched?",
  //         "option1": "1935",
  //         "option2": "1942",
  //         "option3": "1947",
  //         "option4": "1920",
  //         "correct_answer": "1942"
  //       },
  //       {
  //         "question":
  //             "Who was the Viceroy of India during the Quit India Movement?",
  //         "option1": "Lord Irwin",
  //         "option2": "Lord Mountbatten",
  //         "option3": "Lord Wavell",
  //         "option4": "Lord Linlithgow",
  //         "correct_answer": "Lord Linlithgow"
  //       },
  //       {
  //         "question": "Which act introduced the system of dyarchy in India?",
  //         "option1": "Government of India Act 1935",
  //         "option2": "Government of India Act 1919",
  //         "option3": "Indian Independence Act 1947",
  //         "option4": "Rowlatt Act",
  //         "correct_answer": "Government of India Act 1919"
  //       },
  //       {
  //         "question":
  //             "Which session of the INC declared ‘Purna Swaraj’ as its goal?",
  //         "option1": "Nagpur Session, 1920",
  //         "option2": "Lahore Session, 1929",
  //         "option3": "Calcutta Session, 1917",
  //         "option4": "Karachi Session, 1931",
  //         "correct_answer": "Lahore Session, 1929"
  //       },
  //       {
  //         "question": "Who wrote the book 'Discovery of India'?",
  //         "option1": "Mahatma Gandhi",
  //         "option2": "B.R. Ambedkar",
  //         "option3": "Jawaharlal Nehru",
  //         "option4": "Sardar Patel",
  //         "correct_answer": "Jawaharlal Nehru"
  //       }
  //     ],
  //     "3": [
  //       // Chapter 3: The Making of a Global World
  //       {
  //         "question":
  //             "What was the main reason for the European colonization of Asia and Africa?",
  //         "option1": "Spread of Christianity",
  //         "option2": "Search for raw materials and markets",
  //         "option3": "Expansion of democracy",
  //         "option4": "To stop slavery",
  //         "correct_answer": "Search for raw materials and markets"
  //       },
  //       {
  //         "question":
  //             "Which country was the first to industrialize in the 18th century?",
  //         "option1": "Germany",
  //         "option2": "United States",
  //         "option3": "Britain",
  //         "option4": "France",
  //         "correct_answer": "Britain"
  //       },
  //       {
  //         "question":
  //             "Which economic system led to global trade expansion during the colonial period?",
  //         "option1": "Communism",
  //         "option2": "Feudalism",
  //         "option3": "Mercantilism",
  //         "option4": "Socialism",
  //         "correct_answer": "Mercantilism"
  //       },
  //       {
  //         "question": "What was the major outcome of the Opium Wars?",
  //         "option1": "British control over Hong Kong",
  //         "option2": "French control over Vietnam",
  //         "option3": "Indian independence",
  //         "option4": "Russian expansion in China",
  //         "correct_answer": "British control over Hong Kong"
  //       },
  //       {
  //         "question":
  //             "Which country was referred to as the ‘workshop of the world’ during the 19th century?",
  //         "option1": "France",
  //         "option2": "United States",
  //         "option3": "Japan",
  //         "option4": "Britain",
  //         "correct_answer": "Britain"
  //       },
  //       {
  //         "question":
  //             "Which crop was most significant in the triangular slave trade?",
  //         "option1": "Cotton",
  //         "option2": "Sugarcane",
  //         "option3": "Tobacco",
  //         "option4": "Tea",
  //         "correct_answer": "Sugarcane"
  //       },
  //       {
  //         "question": "What was the main purpose of the League of Nations?",
  //         "option1": "To promote world peace",
  //         "option2": "To establish colonial rule",
  //         "option3": "To control world trade",
  //         "option4": "To expand European empires",
  //         "correct_answer": "To promote world peace"
  //       },
  //       {
  //         "question":
  //             "Which event marked the beginning of the Great Depression?",
  //         "option1": "World War I",
  //         "option2": "Wall Street Crash of 1929",
  //         "option3": "Rise of Hitler",
  //         "option4": "Formation of the United Nations",
  //         "correct_answer": "Wall Street Crash of 1929"
  //       },
  //       {
  //         "question":
  //             "Which organization was established after World War II to promote global economic stability?",
  //         "option1": "IMF (International Monetary Fund)",
  //         "option2": "League of Nations",
  //         "option3": "ASEAN",
  //         "option4": "NATO",
  //         "correct_answer": "IMF (International Monetary Fund)"
  //       },
  //       {
  //         "question": "Which treaty officially ended World War I?",
  //         "option1": "Treaty of Paris",
  //         "option2": "Treaty of Versailles",
  //         "option3": "Treaty of Tordesillas",
  //         "option4": "Treaty of London",
  //         "correct_answer": "Treaty of Versailles"
  //       }
  //     ],
  //     "4": [
  //       // Chapter 4: The Age of Industrialisation
  //       {
  //         "question":
  //             "Which country was the first to experience industrialization?",
  //         "option1": "Germany",
  //         "option2": "France",
  //         "option3": "Britain",
  //         "option4": "United States",
  //         "correct_answer": "Britain"
  //       },
  //       {
  //         "question": "Which industry was the first to be industrialized?",
  //         "option1": "Textile Industry",
  //         "option2": "Iron Industry",
  //         "option3": "Coal Industry",
  //         "option4": "Automobile Industry",
  //         "correct_answer": "Textile Industry"
  //       },
  //       {
  //         "question": "Who invented the Spinning Jenny?",
  //         "option1": "James Watt",
  //         "option2": "Richard Arkwright",
  //         "option3": "James Hargreaves",
  //         "option4": "Eli Whitney",
  //         "correct_answer": "James Hargreaves"
  //       },
  //       {
  //         "question": "Which class benefited the most from industrialization?",
  //         "option1": "Nobles",
  //         "option2": "Middle class",
  //         "option3": "Farmers",
  //         "option4": "Peasants",
  //         "correct_answer": "Middle class"
  //       },
  //       {
  //         "question":
  //             "Which Indian industry was severely affected by British industrialization?",
  //         "option1": "Textile Industry",
  //         "option2": "Steel Industry",
  //         "option3": "Automobile Industry",
  //         "option4": "Petroleum Industry",
  //         "correct_answer": "Textile Industry"
  //       },
  //       {
  //         "question":
  //             "Who is known as the 'Father of the Indian Cotton Textile Industry'?",
  //         "option1": "J.N. Tata",
  //         "option2": "Dadabhai Naoroji",
  //         "option3": "Mahatma Gandhi",
  //         "option4": "Raja Ram Mohan Roy",
  //         "correct_answer": "J.N. Tata"
  //       },
  //       {
  //         "question":
  //             "Which of the following was NOT an effect of industrialization?",
  //         "option1": "Urbanization",
  //         "option2": "Increased pollution",
  //         "option3": "Decline in agriculture",
  //         "option4": "Growth of cottage industries",
  //         "correct_answer": "Growth of cottage industries"
  //       },
  //       {
  //         "question":
  //             "Which city in India became a major center for textile production during British rule?",
  //         "option1": "Delhi",
  //         "option2": "Chennai",
  //         "option3": "Mumbai",
  //         "option4": "Kolkata",
  //         "correct_answer": "Mumbai"
  //       },
  //       {
  //         "question":
  //             "Which transportation system played a crucial role in industrialization?",
  //         "option1": "Bullock carts",
  //         "option2": "Railways",
  //         "option3": "Airplanes",
  //         "option4": "Canals",
  //         "correct_answer": "Railways"
  //       },
  //       {
  //         "question":
  //             "Which invention helped increase iron production during the Industrial Revolution?",
  //         "option1": "Power loom",
  //         "option2": "Steam engine",
  //         "option3": "Bessemer process",
  //         "option4": "Cotton gin",
  //         "correct_answer": "Bessemer process"
  //       }
  //     ],
  //     "5": [
  //       // Chapter 5: Print Culture and the Modern World
  //       {
  //         "question": "Who invented the printing press?",
  //         "option1": "Johannes Gutenberg",
  //         "option2": "Leonardo da Vinci",
  //         "option3": "Isaac Newton",
  //         "option4": "Galileo Galilei",
  //         "correct_answer": "Johannes Gutenberg"
  //       },
  //       {
  //         "question":
  //             "Which was the first book printed using Gutenberg's press?",
  //         "option1": "The Quran",
  //         "option2": "The Bible",
  //         "option3": "The Vedas",
  //         "option4": "The Iliad",
  //         "correct_answer": "The Bible"
  //       },
  //       {
  //         "question": "Which of the following was an impact of print culture?",
  //         "option1": "Decline of literacy",
  //         "option2": "Spread of new ideas",
  //         "option3": "Decrease in newspapers",
  //         "option4": "End of book production",
  //         "correct_answer": "Spread of new ideas"
  //       },
  //       {
  //         "question": "In which century did printing technology reach India?",
  //         "option1": "15th century",
  //         "option2": "16th century",
  //         "option3": "17th century",
  //         "option4": "18th century",
  //         "correct_answer": "16th century"
  //       },
  //       {
  //         "question":
  //             "Which language was the first newspaper in India published in?",
  //         "option1": "English",
  //         "option2": "Bengali",
  //         "option3": "Hindi",
  //         "option4": "Urdu",
  //         "correct_answer": "Bengali"
  //       },
  //       {
  //         "question":
  //             "Which social reformer used print culture to spread his ideas in India?",
  //         "option1": "Raja Ram Mohan Roy",
  //         "option2": "Mahatma Gandhi",
  //         "option3": "B.R. Ambedkar",
  //         "option4": "Swami Vivekananda",
  //         "correct_answer": "Raja Ram Mohan Roy"
  //       },
  //       {
  //         "question":
  //             "What was a major result of the print revolution in Europe?",
  //         "option1": "Decline of trade",
  //         "option2": "Rise of the internet",
  //         "option3": "Growth of Renaissance ideas",
  //         "option4": "Increase in slavery",
  //         "correct_answer": "Growth of Renaissance ideas"
  //       },
  //       {
  //         "question": "Which newspaper was started by Mahatma Gandhi?",
  //         "option1": "The Hindu",
  //         "option2": "Harijan",
  //         "option3": "Kesari",
  //         "option4": "Amrit Bazar Patrika",
  //         "correct_answer": "Harijan"
  //       },
  //       {
  //         "question": "Which country first developed woodblock printing?",
  //         "option1": "China",
  //         "option2": "Japan",
  //         "option3": "India",
  //         "option4": "Germany",
  //         "correct_answer": "China"
  //       },
  //       {
  //         "question":
  //             "What was a key feature of the Indian press during British rule?",
  //         "option1": "It was controlled by the government",
  //         "option2": "It spread nationalist ideas",
  //         "option3": "It focused only on religious texts",
  //         "option4": "It was only in English",
  //         "correct_answer": "It spread nationalist ideas"
  //       }
  //     ]
  //   };

  //   WriteBatch batch = FirebaseFirestore.instance.batch();

  //   quizData.forEach((chapterId, quizList) {
  //     CollectionReference quizCollection = FirebaseFirestore.instance
  //         .collection('boards')
  //         .doc(board)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .collection('quiz');

  //     for (int i = 0; i < quizList.length; i++) {
  //       String quizId = "quiz_${i + 1}"; // Naming convention

  //       batch.set(quizCollection.doc(quizId), quizList[i]);
  //     }
  //   });

  //   await batch.commit();
  //   print("✅ Quiz questions uploaded successfully for CBSE History!");
  // }
  Future<void> uploadCBSEMathQuiz() async {
    String board = "CBSE";
    String subject = "Mathematics";

    // Quiz data for each chapter
    Map<String, List<Map<String, dynamic>>> quizData = {
      "1": [
        // Chapter 1: Real Numbers
        {
          "question": "What is the LCM of 12 and 18?",
          "option1": "24",
          "option2": "36",
          "option3": "48",
          "option4": "60",
          "correct_answer": "36"
        },
        {
          "question": "Which of the following is an irrational number?",
          "option1": "√4",
          "option2": "√9",
          "option3": "√2",
          "option4": "8/2",
          "correct_answer": "√2"
        },
        {
          "question": "The decimal expansion of a rational number is always:",
          "option1": "Non-terminating and repeating",
          "option2": "Terminating or repeating",
          "option3": "Non-repeating and non-terminating",
          "option4": "None of the above",
          "correct_answer": "Terminating or repeating"
        },
        {
          "question": "What is the HCF of 24 and 36?",
          "option1": "6",
          "option2": "12",
          "option3": "18",
          "option4": "24",
          "correct_answer": "12"
        },
        {
          "question": "The product of HCF and LCM of two numbers is equal to:",
          "option1": "Their sum",
          "option2": "Their difference",
          "option3": "Their product",
          "option4": "None of these",
          "correct_answer": "Their product"
        },
        {
          "question": "Which of the following is NOT a prime number?",
          "option1": "11",
          "option2": "23",
          "option3": "15",
          "option4": "19",
          "correct_answer": "15"
        },
        {
          "question": "What is the HCF of any two consecutive numbers?",
          "option1": "1",
          "option2": "0",
          "option3": "The smaller number",
          "option4": "The larger number",
          "correct_answer": "1"
        },
        {
          "question": "√25 is equal to:",
          "option1": "4",
          "option2": "5",
          "option3": "6",
          "option4": "7",
          "correct_answer": "5"
        },
        {
          "question": "The decimal representation of 1/7 is:",
          "option1": "Terminating",
          "option2": "Non-terminating and repeating",
          "option3": "Non-terminating and non-repeating",
          "option4": "None of these",
          "correct_answer": "Non-terminating and repeating"
        },
        {
          "question": "What is the LCM of 5, 10, and 15?",
          "option1": "20",
          "option2": "30",
          "option3": "40",
          "option4": "50",
          "correct_answer": "30"
        }
      ],

      "2": [
        // Chapter 2: Polynomials
        {
          "question": "What is the degree of the polynomial 3x² + 4x + 5?",
          "option1": "1",
          "option2": "2",
          "option3": "3",
          "option4": "4",
          "correct_answer": "2"
        },
        {
          "question": "What is a polynomial with only one term called?",
          "option1": "Binomial",
          "option2": "Trinomial",
          "option3": "Monomial",
          "option4": "None of these",
          "correct_answer": "Monomial"
        },
        {
          "question":
              "If x + 1 is a factor of x² + ax + b, what is the remainder when divided?",
          "option1": "0",
          "option2": "a",
          "option3": "b",
          "option4": "1",
          "correct_answer": "0"
        },
        {
          "question": "Which of the following is NOT a polynomial?",
          "option1": "x² + 3x - 5",
          "option2": "x⁵ + 2x",
          "option3": "1/x",
          "option4": "3x³ + 2x² + 7",
          "correct_answer": "1/x"
        },
        {
          "question": "What is the sum of the zeroes of x² - 5x + 6?",
          "option1": "2",
          "option2": "3",
          "option3": "5",
          "option4": "6",
          "correct_answer": "5"
        },
        {
          "question": "What is the degree of a constant polynomial?",
          "option1": "0",
          "option2": "1",
          "option3": "2",
          "option4": "3",
          "correct_answer": "0"
        },
        {
          "question":
              "If one zero of a quadratic polynomial is 2, what is the other if the sum is 5?",
          "option1": "1",
          "option2": "2",
          "option3": "3",
          "option4": "4",
          "correct_answer": "3"
        },
        {
          "question": "A polynomial with exactly two terms is called:",
          "option1": "Monomial",
          "option2": "Binomial",
          "option3": "Trinomial",
          "option4": "Quadrinomial",
          "correct_answer": "Binomial"
        },
        {
          "question": "Which one is a quadratic polynomial?",
          "option1": "x + 3",
          "option2": "x² + 2x + 1",
          "option3": "x³ + x + 5",
          "option4": "x⁴ + 1",
          "correct_answer": "x² + 2x + 1"
        },
        {
          "question":
              "If (x - 2) is a factor of x² - 4x + 4, what is the other factor?",
          "option1": "(x - 1)",
          "option2": "(x - 2)",
          "option3": "(x + 2)",
          "option4": "(x + 1)",
          "correct_answer": "(x - 2)"
        }
      ],
      "3": [
        // Chapter 3: Linear Equations in Two Variables
        {
          "question": "A linear equation in two variables represents a:",
          "option1": "Point",
          "option2": "Line",
          "option3": "Circle",
          "option4": "Parabola",
          "correct_answer": "Line"
        },
        {
          "question":
              "The general form of a linear equation in two variables is:",
          "option1": "ax + by = c",
          "option2": "ax² + bx + c = 0",
          "option3": "ax³ + bx² + c = 0",
          "option4": "None of these",
          "correct_answer": "ax + by = c"
        },
        {
          "question":
              "How many solutions does a pair of inconsistent linear equations have?",
          "option1": "One",
          "option2": "Infinite",
          "option3": "None",
          "option4": "Two",
          "correct_answer": "None"
        },
        {
          "question": "If two linear equations are coincident, they have:",
          "option1": "No solution",
          "option2": "Infinite solutions",
          "option3": "Unique solution",
          "option4": "None of these",
          "correct_answer": "Infinite solutions"
        },
        {
          "question":
              "If a pair of linear equations has a unique solution, the lines are:",
          "option1": "Parallel",
          "option2": "Coincident",
          "option3": "Intersecting",
          "option4": "None of these",
          "correct_answer": "Intersecting"
        },
        {
          "question": "What is the graphical representation of 2x + 3y = 6?",
          "option1": "A parabola",
          "option2": "A straight line",
          "option3": "A circle",
          "option4": "An ellipse",
          "correct_answer": "A straight line"
        },
        {
          "question":
              "If two equations represent the same line, they are called:",
          "option1": "Parallel equations",
          "option2": "Coincident equations",
          "option3": "Intersecting equations",
          "option4": "None of these",
          "correct_answer": "Coincident equations"
        },
        {
          "question": "Which of the following is NOT a linear equation?",
          "option1": "x + y = 3",
          "option2": "2x - 5y = 7",
          "option3": "x² + y = 5",
          "option4": "4x + 3y = 12",
          "correct_answer": "x² + y = 5"
        },
        {
          "question": "The pair of equations 2x + 3y = 5 and 4x + 6y = 10 are:",
          "option1": "Consistent",
          "option2": "Inconsistent",
          "option3": "Dependent",
          "option4": "Independent",
          "correct_answer": "Dependent"
        },
        {
          "question":
              "If a system of linear equations has no solution, the lines are:",
          "option1": "Parallel",
          "option2": "Coincident",
          "option3": "Intersecting",
          "option4": "Perpendicular",
          "correct_answer": "Parallel"
        }
      ],

      "4": [
        // Chapter 4: Quadratic Equations
        {
          "question": "What is the standard form of a quadratic equation?",
          "option1": "ax + b = 0",
          "option2": "ax² + bx + c = 0",
          "option3": "ax³ + bx² + c = 0",
          "option4": "None of these",
          "correct_answer": "ax² + bx + c = 0"
        },
        {
          "question": "How many solutions does a quadratic equation have?",
          "option1": "1",
          "option2": "2",
          "option3": "3",
          "option4": "Infinite",
          "correct_answer": "2"
        },
        {
          "question":
              "The roots of a quadratic equation are given by the formula:",
          "option1": "(-b ± √(b² - 4ac))/2a",
          "option2": "(-b ± 4ac)/2a",
          "option3": "(-b ± √(4ac - b²))/2a",
          "option4": "None of these",
          "correct_answer": "(-b ± √(b² - 4ac))/2a"
        },
        {
          "question": "If the discriminant (b² - 4ac) < 0, then the roots are:",
          "option1": "Real and distinct",
          "option2": "Real and equal",
          "option3": "Imaginary",
          "option4": "None of these",
          "correct_answer": "Imaginary"
        },
        {
          "question":
              "A quadratic equation has equal roots when the discriminant is:",
          "option1": "Positive",
          "option2": "Negative",
          "option3": "Zero",
          "option4": "None of these",
          "correct_answer": "Zero"
        },
        {
          "question": "If one root of x² - 5x + 6 = 0 is 2, the other root is:",
          "option1": "1",
          "option2": "3",
          "option3": "4",
          "option4": "5",
          "correct_answer": "3"
        },
        {
          "question": "Which of the following represents a quadratic equation?",
          "option1": "x + 3 = 0",
          "option2": "x² + 3x + 2 = 0",
          "option3": "x³ - 5x + 6 = 0",
          "option4": "None of these",
          "correct_answer": "x² + 3x + 2 = 0"
        },
        {
          "question":
              "If a quadratic equation has real and distinct roots, then the discriminant is:",
          "option1": "Zero",
          "option2": "Positive",
          "option3": "Negative",
          "option4": "None of these",
          "correct_answer": "Positive"
        },
        {
          "question":
              "The sum of the roots of the equation ax² + bx + c = 0 is:",
          "option1": "-b/a",
          "option2": "b/a",
          "option3": "-c/a",
          "option4": "c/a",
          "correct_answer": "-b/a"
        },
        {
          "question":
              "The product of the roots of the equation ax² + bx + c = 0 is:",
          "option1": "b/a",
          "option2": "-b/a",
          "option3": "c/a",
          "option4": "-c/a",
          "correct_answer": "c/a"
        }
      ],

      "5": [
        {
          "question": "What is the formula for the nth term of an A.P.?",
          "option1": "a + (n-1)d",
          "option2": "a - (n-1)d",
          "option3": "a + nd",
          "option4": "a - nd",
          "correct_answer": "a + (n-1)d"
        },
        {
          "question": "What is the common difference (d) in an A.P.?",
          "option1": "The difference between consecutive terms",
          "option2": "The sum of all terms",
          "option3": "The product of all terms",
          "option4": "The last term minus first term",
          "correct_answer": "The difference between consecutive terms"
        },
        {
          "question":
              "Which of the following sequences is an arithmetic progression?",
          "option1": "2, 4, 8, 16",
          "option2": "5, 10, 15, 20",
          "option3": "3, 6, 12, 24",
          "option4": "1, 4, 9, 16",
          "correct_answer": "5, 10, 15, 20"
        },
        {
          "question": "What is the sum of the first n terms of an A.P.?",
          "option1": "Sn = n/2 [2a + (n-1)d]",
          "option2": "Sn = 2a + (n-1)d",
          "option3": "Sn = a + (n-1)d",
          "option4": "Sn = n/2 [2a - (n-1)d]",
          "correct_answer": "Sn = n/2 [2a + (n-1)d]"
        },
        {
          "question":
              "If the first term of an A.P. is 3 and common difference is 2, what is the 10th term?",
          "option1": "21",
          "option2": "22",
          "option3": "23",
          "option4": "24",
          "correct_answer": "21"
        },
        {
          "question":
              "Which of the following is the first term in an arithmetic sequence?",
          "option1": "The last term",
          "option2": "The common difference",
          "option3": "The starting number",
          "option4": "The sum of the sequence",
          "correct_answer": "The starting number"
        },
        {
          "question":
              "If the sum of the first 5 terms of an A.P. is 40 and the first term is 4, what is the common difference?",
          "option1": "2",
          "option2": "3",
          "option3": "4",
          "option4": "5",
          "correct_answer": "2"
        },
        {
          "question": "In an A.P., if a = 7 and d = 3, what is the 8th term?",
          "option1": "25",
          "option2": "27",
          "option3": "29",
          "option4": "31",
          "correct_answer": "28"
        },
        {
          "question": "What type of sequence is 50, 45, 40, 35, ...?",
          "option1": "Arithmetic",
          "option2": "Geometric",
          "option3": "Fibonacci",
          "option4": "None of these",
          "correct_answer": "Arithmetic"
        },
        {
          "question":
              "If an A.P. has a = 1 and d = 2, what is the sum of the first 10 terms?",
          "option1": "100",
          "option2": "110",
          "option3": "55",
          "option4": "50",
          "correct_answer": "55"
        }
        // Add 9 more questions...
      ]

      // Add similar data for chapters 3, 4, and 5
    };

    WriteBatch batch = FirebaseFirestore.instance.batch();

    quizData.forEach((chapterId, quizList) {
      CollectionReference quizCollection = FirebaseFirestore.instance
          .collection('boards')
          .doc(board)
          .collection('subjects')
          .doc(subject)
          .collection('chapters')
          .doc(chapterId)
          .collection('quiz');

      for (int i = 0; i < quizList.length; i++) {
        String quizId = "quiz_${i + 1}"; // Naming convention

        batch.set(quizCollection.doc(quizId), quizList[i]);
      }
    });

    await batch.commit();
    print(
        "✅ Quiz questions uploaded successfully for CBSE Mathematics Chapters!");
  }
}
