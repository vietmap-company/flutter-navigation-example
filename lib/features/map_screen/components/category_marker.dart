 
import 'package:flutter/material.dart';

import '../../../data/models/vietmap_reverse_model.dart';
import '../bloc/bloc.dart';

class CategoryMarker extends StatelessWidget {
  const CategoryMarker({super.key, required this.model});
  final VietmapReverseModel model;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<MapBloc>().add(MapEventShowPlaceDetail(model));
      },
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                model.name ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.location_pin, size: 40, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
