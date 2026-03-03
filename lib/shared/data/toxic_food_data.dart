import 'package:petalert/shared/models/toxic_food.dart';

const toxicFoods = <ToxicFood>[
  ToxicFood(
    name: 'Chocolate',
    category: 'Toxic',
    shortInfo: 'Can cause vomiting, diarrhea, seizures.',
    details:
        'Chocolate contains theobromine and caffeine. Dark chocolate is the most dangerous. If ingested, contact a vet ASAP.',
  ),
  ToxicFood(
    name: 'Grapes & Raisins',
    category: 'Toxic',
    shortInfo: 'Can cause kidney failure (dogs).',
    details:
        'Even small amounts can be dangerous for some dogs. Symptoms: vomiting, lethargy. Vet immediately.',
  ),
  ToxicFood(
    name: 'Onion & Garlic',
    category: 'Toxic',
    shortInfo: 'Damages red blood cells (dogs/cats).',
    details:
        'Found in cooked food too. Watch for weakness, pale gums. Vet visit recommended.',
  ),
  ToxicFood(
    name: 'Xylitol (sugar-free gum)',
    category: 'Toxic',
    shortInfo: 'Can cause low blood sugar and liver damage.',
    details:
        'Extremely dangerous for dogs. This is an emergency. Go to ER vet immediately.',
  ),
  ToxicFood(
    name: 'Plain boiled chicken',
    category: 'Safe',
    shortInfo: 'Gentle on stomach for many dogs.',
    details:
        'Useful for upset stomach. Avoid seasoning, onion, garlic, and bones.',
  ),
  ToxicFood(
    name: 'Emergency: Vet / Poison Help',
    category: 'Emergency',
    shortInfo: 'Call your vet or pet poison support.',
    details:
        'If severe symptoms (collapse, seizures, trouble breathing), go to an emergency vet immediately.',
  ),
];