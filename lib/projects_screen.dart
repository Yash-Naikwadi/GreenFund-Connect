import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'project_details_screen.dart';
import 'featured_project_card.dart';
import 'project_grid.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Featured Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FeaturedProjectCard(
                title: 'Solar Village Initiative',
                location: 'Maharashtra, India',
                fundingPercentage: 75,
                imageAsset: 'assets/images/solar_village.png',
                onTap: () {
                  Navigator.pushNamed(context, '/project_details');
                },
              ),
              FeaturedProjectCard(
                title: 'Wind Power Hub',
                location: 'Tamil Nadu, India',
                fundingPercentage: 45,
                imageAsset: 'assets/images/wind_power.png',
                onTap: () {
                  Navigator.pushNamed(context, '/project_details');
                },
              ),
              FeaturedProjectCard(
                title: 'Community Hydro Plant',
                location: 'Himachal Pradesh, India',
                fundingPercentage: 60,
                imageAsset: 'assets/images/hydro_plant.png',
                onTap: () {
                  Navigator.pushNamed(context, '/project_details');
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'All Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(child: ProjectGrid()),
      ],
    );
  }
}
