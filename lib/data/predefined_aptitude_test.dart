class PredefinedAptitudeTest {
  static const String sectionScience = 'Science';
  static const String sectionCommerce = 'Commerce';
  static const String sectionHumanities = 'Humanities';

  /// Get fallback questions for a specific education level
  static List<Map<String, dynamic>> getQuestions(String educationLevel) {
    switch (educationLevel) {
      case '10th':
        return _questions10th;
      case '12th':
        return _questions12th;
      case 'Diploma':
        return _questionsDiploma;
      case 'Bachelor':
        return _questionsBachelor;
      case 'Master':
        return _questionsMaster;
      default:
        return _questions10th;
    }
  }

  /// Analyze results locally when AI fails
  static Map<String, dynamic> analyzeResults(
    List<Map<String, dynamic>> questions,
    Map<String, String> answers,
  ) {
    int score = 0;
    int scienceScore = 0;
    int scienceTotal = 0;
    int commerceScore = 0;
    int commerceTotal = 0;
    int humanitiesScore = 0;
    int humanitiesTotal = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      // Use index as key (as string) to match frontend behavior
      final key = i.toString();
      final userAnswerLetter = answers[key];
      final correctOptionIndex =
          (question['correct_option'] as num?)?.toInt() ?? 0;
      final section = (question['section'] as String?) ?? 'General';

      if (section == sectionScience) scienceTotal++;
      if (section == sectionCommerce) commerceTotal++;
      if (section == sectionHumanities) humanitiesTotal++;

      if (userAnswerLetter != null) {
        final userAnswerIndex = userAnswerLetter.codeUnitAt(0) - 65; // A=0, B=1

        if (userAnswerIndex == correctOptionIndex) {
          score++;
          if (section == sectionScience) scienceScore++;
          if (section == sectionCommerce) commerceScore++;
          if (section == sectionHumanities) humanitiesScore++;
        }
      }
    }

    // Determine strongest stream
    String suggestedStream = 'General';
    String description = '';

    // Simple max logic
    if (scienceScore >= commerceScore && scienceScore >= humanitiesScore) {
      suggestedStream = 'Science & Technology';
      description =
          'You show strong analytical and problem-solving skills, suggesting a natural fit for Science, Engineering, or Technology fields.';
    } else if (commerceScore >= scienceScore &&
        commerceScore >= humanitiesScore) {
      suggestedStream = 'Commerce & Business';
      description =
          'You have a good grasp of logic, data, and management concepts, making you well-suited for Commerce, Business, or Finance roles.';
    } else {
      suggestedStream = 'Humanities & Arts';
      description =
          'You demonstrate strong creative, verbal, and social reasoning skills, pointing towards success in Arts, Humanities, or Social Sciences.';
    }

    return {
      'score': score,
      'total_questions': questions.length,
      'ai_analysis': {
        'strong_areas': [
          'Demonstrated aptitude in $suggestedStream',
          if (score > 7) 'High overall accuracy',
          if (score > 5 && score <= 7) 'Good general knowledge',
        ],
        'weak_areas': [
          if (scienceScore < 2) 'Scientific concepts could be strengthened',
          if (commerceScore < 2) 'Business logic areas might need review',
          if (humanitiesScore < 2)
            'Verbal/Creative reasoning is an area for growth',
        ],
        'suggested_careers': _getCareersForStream(suggestedStream),
        'improvement_tips': [
          'Focus on your strong areas in $suggestedStream.',
          'Practice more questions to improve speed and accuracy.',
          'Consider talking to a career counselor for a detailed roadmap.',
        ],
        'summary':
            'Based on your test performance, your aptitude profile aligns best with **$suggestedStream**. $description',
      },
      'category_breakdown': {
        'Science': {'correct': scienceScore, 'total': scienceTotal},
        'Commerce': {'correct': commerceScore, 'total': commerceTotal},
        'Humanities': {'correct': humanitiesScore, 'total': humanitiesTotal},
      },
      'is_fallback': true, // Flag to indicate local fallback
    };
  }

  static List<String> _getCareersForStream(String stream) {
    if (stream.contains('Science')) {
      return [
        'Software Engineer',
        'Data Scientist',
        'Doctor',
        'Researcher',
        'Civil Engineer',
      ];
    } else if (stream.contains('Commerce')) {
      return [
        'Chartered Accountant',
        'Investment Banker',
        'Marketing Manager',
        'Business Analyst',
        'Entrepreneur',
      ];
    } else {
      return [
        'Journalist',
        'Graphic Designer',
        'Psychologist',
        'Content Writer',
        'Teacher',
      ];
    }
  }

  // --- 10th Standard Questions ---
  static final List<Map<String, dynamic>> _questions10th = [
    {
      'id': 1001,
      'question':
          'If a car travels 60 km in 1.5 hours, what is its average speed?',
      'options': ['30 km/h', '40 km/h', '45 km/h', '50 km/h'],
      'correct_option': 1, // 40 km/h
      'section': sectionScience,
    },
    {
      'id': 1002,
      'question': 'Which of these is a renewable source of energy?',
      'options': ['Coal', 'Natural Gas', 'Solar Power', 'Petroleum'],
      'correct_option': 2, // Solar
      'section': sectionScience,
    },
    {
      'id': 1003,
      'question': 'H2O is the chemical formula for:',
      'options': ['Hydrogen', 'Oxygen', 'Water', 'Salt'],
      'correct_option': 2, // Water
      'section': sectionScience,
    },
    {
      'id': 1004,
      'question': 'Profit is calculated as:',
      'options': [
        'Cost Price - Selling Price',
        'Selling Price - Cost Price',
        'Selling Price + Cost Price',
        'None of these',
      ],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1005,
      'question':
          'A shopkeeper gives a 10% discount on an item costing \$100. What is the final price?',
      'options': ['\$80', '\$85', '\$90', '\$95'],
      'correct_option': 2, // 90
      'section': sectionCommerce,
    },
    {
      'id': 1006,
      'question': 'What is the primary role of a bank?',
      'options': [
        'To print money',
        'To accept deposits and lend money',
        'To sell goods',
        'To build houses',
      ],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1007,
      'question': 'Who wrote the play "Romeo and Juliet"?',
      'options': [
        'Charles Dickens',
        'William Shakespeare',
        'Mark Twain',
        'Jane Austen',
      ],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1008,
      'question': 'Which color symbolizes peace?',
      'options': ['Red', 'White', 'Black', 'Green'],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1009,
      'question': 'Identify the noun in the sentence: "The cat runs fast."',
      'options': ['Runs', 'Fast', 'Cat', 'The'],
      'correct_option': 2,
      'section': sectionHumanities,
    },
    {
      'id': 1010,
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'correct_option': 1,
      'section': sectionScience,
    },
  ];

  // --- 12th Standard Questions ---
  static final List<Map<String, dynamic>> _questions12th = [
    {
      'id': 1201,
      'question': 'What is the derivative of x^2?',
      'options': ['x', '2x', 'x^2', '2'],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1202,
      'question': 'Newton’s Second Law is defined as:',
      'options': ['F = ma', 'E = mc^2', 'P = mv', 'V = IR'],
      'correct_option': 0,
      'section': sectionScience,
    },
    {
      'id': 1203,
      'question': 'In a balance sheet, Assets = Liabilities + ?',
      'options': ['Revenue', 'Expenses', 'Equity', 'Loan'],
      'correct_option': 2,
      'section': sectionCommerce,
    },
    {
      'id': 1204,
      'question': 'Which market deals with long-term finance?',
      'options': [
        'Money Market',
        'Capital Market',
        'Vegetable Market',
        'Black Market',
      ],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1205,
      'question':
          'The study of human society and social relationships is called:',
      'options': ['Psychology', 'Sociology', 'Biology', 'Geology'],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1206,
      'question': 'Who was the first President of the United States?',
      'options': [
        'Abraham Lincoln',
        'George Washington',
        'Thomas Jefferson',
        'John Adams',
      ],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1207,
      'question': 'What is the powerhouse of the cell?',
      'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi body'],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1208,
      'question': 'A debit entry in a bank passbook indicates:',
      'options': ['Deposit', 'Withdrawal', 'Interest Earned', 'None of these'],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1209,
      'question': 'Which literary device uses "like" or "as" for comparison?',
      'options': ['Metaphor', 'Simile', 'Alliteration', 'Hyperbole'],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1210,
      'question': 'What is the value of Pi (approx)?',
      'options': ['3.14', '2.14', '4.14', '3.41'],
      'correct_option': 0,
      'section': sectionScience,
    },
  ];

  // --- Diploma Questions ---
  static final List<Map<String, dynamic>> _questionsDiploma = [
    {
      'id': 1301,
      'question': 'Which component is used to store charge in a circuit?',
      'options': ['Resistor', 'Inductor', 'Capacitor', 'Diode'],
      'correct_option': 2,
      'section': sectionScience,
    },
    {
      'id': 1302,
      'question':
          'The process of turning raw materials into finished goods is:',
      'options': ['Manufacturing', 'Mining', 'Farming', 'Trading'],
      'correct_option': 0,
      'section': sectionCommerce,
    },
    {
      'id': 1303,
      'question': 'Communication that occurs without words is called:',
      'options': ['Verbal', 'Non-verbal', 'Written', 'Oral'],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1304,
      'question': 'Ohm’s Law formula is:',
      'options': ['V = IR', 'P = IV', 'E = mc^2', 'F = ma'],
      'correct_option': 0,
      'section': sectionScience,
    },
    {
      'id': 1305,
      'question': 'What does ROI stand for in business?',
      'options': [
        'Rate of Interest',
        'Return on Investment',
        'Risk of Inflation',
        'Return of Income',
      ],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1306,
      'question': 'Which software is primarily used for technical drawing?',
      'options': ['Photoshop', 'AutoCAD', 'Excel', 'Word'],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1307,
      'question': 'The 4 Ps of Marketing are Product, Price, Place, and...?',
      'options': ['People', 'Process', 'Promotion', 'Planning'],
      'correct_option': 2,
      'section': sectionCommerce,
    },
    {
      'id': 1308,
      'question': 'Effective teamwork requires primarily:',
      'options': ['Competition', 'Communication', 'Isolation', 'Silence'],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1309,
      'question': 'What is the main function of a CPU?',
      'options': [
        'Store data',
        'Process instructions',
        'Display images',
        'Play sound',
      ],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1310,
      'question':
          'A concise document highlighting a person\'s skills and experience is a:',
      'options': ['Memo', 'Report', 'Resume', 'Notice'],
      'correct_option': 2,
      'section': sectionHumanities,
    },
  ];

  // --- Bachelor Questions ---
  static final List<Map<String, dynamic>> _questionsBachelor = [
    {
      'id': 1401,
      'question': 'In programming, what does OOP stand for?',
      'options': [
        'Object Oriented Programming',
        'Over Ordered Processing',
        'Only Object Protocol',
        'Open Operation Process',
      ],
      'correct_option': 0,
      'section': sectionScience,
    },
    {
      'id': 1402,
      'question': 'An oligopoly is a market structure with:',
      'options': ['One seller', 'Few sellers', 'Many sellers', 'No sellers'],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1403,
      'question':
          'Which philosopher is associated with "I think, therefore I am"?',
      'options': ['Socrates', 'Plato', 'Descartes', 'Nietzsche'],
      'correct_option': 2,
      'section': sectionHumanities,
    },
    {
      'id': 1404,
      'question': 'Which data structure follows LIFO (Last In First Out)?',
      'options': ['Queue', 'Array', 'Stack', 'Linked List'],
      'correct_option': 2,
      'section': sectionScience,
    },
    {
      'id': 1405,
      'question': 'What is "GDP"?',
      'options': [
        'Gross Domestic Product',
        'General Domestic Price',
        'Global Development Plan',
        'Gross Dollar Profit',
      ],
      'correct_option': 0,
      'section': sectionCommerce,
    },
    {
      'id': 1406,
      'question': 'Thermodynamics deals with:',
      'options': ['Motion', 'Heat and Energy', 'Light', 'Sound'],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1407,
      'question': 'Venture Capital is money provided to:',
      'options': [
        'High-potential startups',
        'Stable government bonds',
        'Bank accounts',
        'Failing companies',
      ],
      'correct_option': 0,
      'section': sectionCommerce,
    },
    {
      'id': 1408,
      'question': 'Abstract Art is characterized by:',
      'options': [
        'Realistic depiction',
        'Lack of definable subject matter',
        'Historical events',
        'Portraits',
      ],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1409,
      'question': 'DNA replication occurs in which part of the cell?',
      'options': ['Ribosome', 'Nucleus', 'Cytoplasm', 'Membrane'],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1410,
      'question': 'Ethics is best defined as:',
      'options': [
        'Laws of a country',
        'Moral principles governing behavior',
        'Religious texts',
        'Company policies',
      ],
      'correct_option': 1,
      'section': sectionHumanities,
    },
  ];

  // --- Master Questions ---
  static final List<Map<String, dynamic>> _questionsMaster = [
    {
      'id': 1501,
      'question': 'Which algorithm is used for shortest path finding?',
      'options': ['Bubble Sort', 'Dijkstra', 'Binary Search', 'K-Means'],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1502,
      'question': 'In management, SWOT analysis stands for:',
      'options': [
        'Strengths, Weaknesses, Opportunities, Threats',
        'Sales, Work, Orders, Time',
        'Strategy, Wealth, Organization, Team',
        'None of these',
      ],
      'correct_option': 0,
      'section': sectionCommerce,
    },
    {
      'id': 1503,
      'question': 'Post-Modernism is a reaction against:',
      'options': ['Classicism', 'Modernism', 'Realism', 'Romanticism'],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1504,
      'question': 'Quantum Entanglement refers to:',
      'options': [
        'Particles remaining connected over distance',
        'Particles colliding',
        'Energy loss',
        'Gravity',
      ],
      'correct_option': 0,
      'section': sectionScience,
    },
    {
      'id': 1505,
      'question': 'A "Bear Market" indicates:',
      'options': [
        'Rising prices',
        'Falling prices',
        'Stable prices',
        'Volatile prices',
      ],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1506,
      'question': 'The Turing Test is used to determine:',
      'options': [
        'Computer speed',
        'Machine intelligence',
        'Network security',
        'Data storage',
      ],
      'correct_option': 1,
      'section': sectionScience,
    },
    {
      'id': 1507,
      'question': 'Corporate Social Responsibility (CSR) implies:',
      'options': [
        'Maximizing profit only',
        'Business contribution to societal goals',
        'Paying taxes',
        'Employee parties',
      ],
      'correct_option': 1,
      'section': sectionCommerce,
    },
    {
      'id': 1508,
      'question': 'Epistemology is the study of:',
      'options': ['Ethics', 'Knowledge', 'Existence', 'Art'],
      'correct_option': 1,
      'section': sectionHumanities,
    },
    {
      'id': 1509,
      'question': 'Big Data is characterized by Volume, Velocity, and...?',
      'options': ['Variety', 'Victory', 'Vision', 'Voice'],
      'correct_option': 0,
      'section': sectionScience,
    },
    {
      'id': 1510,
      'question': 'Fiscal Policy is managed by:',
      'options': [
        'The Central Bank',
        'The Government',
        'Private Banks',
        'Stock Market',
      ],
      'correct_option': 1,
      'section': sectionCommerce,
    },
  ];
}
