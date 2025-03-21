import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'project_card.dart';

class ProjectGrid extends StatelessWidget {
  ProjectGrid({Key? key}) : super(key: key);

  final List projects = [
    {
      "title": "Solar Village",
      "description": "Solar power for rural communities",
      "location": "Maharashtra",
      "icon": Icons.wb_sunny,
      "fundingPercentage": 75,
      "imageAsset": "assets/images/solar_village.png",
    },
    {
      "title": "Wind Power Hub",
      "description": "Coastal wind energy farm",
      "location": "Tamil Nadu",
      "icon": Icons.air,
      "fundingPercentage": 45,
      "imageAsset": "assets/images/wind_power.png",
    },
    {
      "title": "Hydro Plant",
      "description": "Small-scale hydro electricity",
      "location": "Himachal Pradesh",
      "icon": Icons.water,
      "fundingPercentage": 60,
      "imageAsset": "assets/images/hydro_plant.png",
    },
    {
      "title": "Bioenergy Farm",
      "description": "Agricultural waste to energy",
      "location": "Punjab",
      "icon": Icons.eco,
      "fundingPercentage": 30,
      "imageAsset": "assets/images/bioenergy_farm.png",
    },
    {
      "title": "Community Solar",
      "description": "Rooftop solar for apartments",
      "location": "Karnataka",
      "icon": Icons.house,
      "fundingPercentage": 80,
      "imageAsset": "assets/images/community_solar.png",
    },
    {
      "title": "Green School",
      "description": "Renewable energy for education",
      "location": "Delhi",
      "icon": Icons.school,
      "fundingPercentage": 55,
      "imageAsset": "assets/images/green_school.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return ProjectCard(
          title: projects[index]["title"],
          description: projects[index]["description"],
          location: projects[index]["location"],
          icon: projects[index]["icon"],
          fundingPercentage: projects[index]["fundingPercentage"],
          imageAsset: projects[index]["imageAsset"],
        );
      },
    );
  }
}
