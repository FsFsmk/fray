import 'package:fray/models/headache_enum.dart';

class HeadacheClassifaction {
  String name;
  List<HeadacheLocation>? possibleLocations;
  List<HeadacheQuality>? possibleQualities;
  List<HeadacheIntensity>? possibleIntensityLevels;

  HeadacheClassifaction({
    required this.name,
    this.possibleQualities,
    this.possibleIntensityLevels,
    this.possibleLocations,
  });
}

List<HeadacheClassifaction> headacheClassifications = [
  // Primary Headache Disorders
  HeadacheClassifaction(
    name: "Migraine without Aura",
    possibleLocations: [
      HeadacheLocation.unilateral,
      HeadacheLocation.temporal,
      HeadacheLocation.frontal,
    ],
    possibleQualities: [
      HeadacheQuality.throbbing,
      HeadacheQuality.pulsating,
      HeadacheQuality.stabbing,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Migraine with Aura",
    possibleLocations: [
      HeadacheLocation.unilateral,
      HeadacheLocation.temporal,
      HeadacheLocation.frontal,
      HeadacheLocation.eyebrowsOrEyesArea,
    ],
    possibleQualities: [
      HeadacheQuality.throbbing,
      HeadacheQuality.pulsating,
      HeadacheQuality.electricShockLike,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Tension-Type Headache",
    possibleLocations: [
      HeadacheLocation.bilateral,
      HeadacheLocation.pericranial,
      HeadacheLocation.temporal,
      HeadacheLocation.frontal,
    ],
    possibleQualities: [
      HeadacheQuality.pressingOrTightening,
      HeadacheQuality.dull,
      HeadacheQuality.aching,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.mild,
      HeadacheIntensity.moderate,
    ],
  ),
  HeadacheClassifaction(
    name: "Cluster Headache",
    possibleLocations: [
      HeadacheLocation.unilateral,
      HeadacheLocation.eyebrowsOrEyesArea,
      HeadacheLocation.temporal,
      HeadacheLocation.facialOrNeck,
    ],
    possibleQualities: [
      HeadacheQuality.stabbing,
      HeadacheQuality.shooting,
      HeadacheQuality.sharp,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.severe,
    ],
  ),

  // Secondary Headache Disorders
  HeadacheClassifaction(
    name: "Headache Attributed to Trauma or Injury to the Head and/or Neck",
    possibleLocations: [
      HeadacheLocation.unilateral,
      HeadacheLocation.bilateral,
      HeadacheLocation.neck,
      HeadacheLocation.frontal,
    ],
    possibleQualities: [
      HeadacheQuality.dull,
      HeadacheQuality.aching,
      HeadacheQuality.pulsating,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.mild,
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Headache Attributed to Cranial or Cervical Vascular Disorder",
    possibleLocations: [
      HeadacheLocation.unilateral,
      HeadacheLocation.bilateral,
      HeadacheLocation.frontal,
      HeadacheLocation.temporal,
    ],
    possibleQualities: [
      HeadacheQuality.throbbing,
      HeadacheQuality.sharp,
      HeadacheQuality.pressingOrTightening,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Headache Attributed to Non-Vascular Intracranial Disorder",
    possibleLocations: [
      HeadacheLocation.unilateral,
      HeadacheLocation.bilateral,
      HeadacheLocation.frontal,
    ],
    possibleQualities: [
      HeadacheQuality.stabbing,
      HeadacheQuality.dull,
      HeadacheQuality.aching,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Headache Attributed to Infection",
    possibleLocations: [
      HeadacheLocation.bilateral,
      HeadacheLocation.frontal,
      HeadacheLocation.temporal,
    ],
    possibleQualities: [
      HeadacheQuality.dull,
      HeadacheQuality.throbbing,
      HeadacheQuality.pressingOrTightening,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.mild,
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Headache Attributed to Substance Use or Withdrawal",
    possibleLocations: [
      HeadacheLocation.bilateral,
      HeadacheLocation.frontal,
      HeadacheLocation.temporal,
    ],
    possibleQualities: [
      HeadacheQuality.dull,
      HeadacheQuality.aching,
      HeadacheQuality.pressingOrTightening,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.mild,
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Headache Attributed to Disorder of Homeostasis",
    possibleLocations: [
      HeadacheLocation.bilateral,
      HeadacheLocation.frontal,
      HeadacheLocation.occipital,
    ],
    possibleQualities: [
      HeadacheQuality.throbbing,
      HeadacheQuality.dull,
      HeadacheQuality.pulsating,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Headache Attributed to Facial Pain or Disorder of the Neck",
    possibleLocations: [
      HeadacheLocation.facialOrNeck,
      HeadacheLocation.mouthOrOtherFacialOrCervicalStructure,
    ],
    possibleQualities: [
      HeadacheQuality.stabbing,
      HeadacheQuality.aching,
      HeadacheQuality.shooting,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.moderate,
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Headache Attributed to Psychiatric Disorder",
    possibleLocations: [
      HeadacheLocation.bilateral,
      HeadacheLocation.frontal,
      HeadacheLocation.temporal,
    ],
    possibleQualities: [
      HeadacheQuality.dull,
      HeadacheQuality.aching,
      HeadacheQuality.pressingOrTightening,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.mild,
      HeadacheIntensity.moderate,
    ],
  ),

  // Cranial Neuralgias, Central and Primary Facial Pain, and Other Headaches
  HeadacheClassifaction(
    name: "Trigeminal Neuralgia",
    possibleLocations: [
      HeadacheLocation.facialOrNeck,
      HeadacheLocation.mouthOrOtherFacialOrCervicalStructure,
    ],
    possibleQualities: [
      HeadacheQuality.shooting,
      HeadacheQuality.electricShockLike,
      HeadacheQuality.stabbing,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.severe,
    ],
  ),
  HeadacheClassifaction(
    name: "Persistent Idiopathic Facial Pain",
    possibleLocations: [
      HeadacheLocation.facialOrNeck,
    ],
    possibleQualities: [
      HeadacheQuality.aching,
      HeadacheQuality.dull,
    ],
    possibleIntensityLevels: [
      HeadacheIntensity.mild,
      HeadacheIntensity.moderate,
    ],
  ),
];
