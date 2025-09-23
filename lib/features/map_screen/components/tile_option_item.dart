import 'package:flutter/material.dart';
import 'package:vietmap_map/features/map_screen/bloc/bloc.dart';

import 'select_map_tiles_modal.dart';

class TileOptionItem extends StatelessWidget {
  const TileOptionItem(
      {super.key, required this.mapType, required this.currentMapType});
  final MapTiles mapType;
  final MapTiles currentMapType;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<MapBloc>().add(MapEventChangeMapTiles(mapType));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: mapType == currentMapType
                    ? Border.all(
                        color: Theme.of(context).primaryColor, width: 2)
                    : null),
            child: ClipRRect(
              child: getMapTypeOptionsImage(mapType),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          SizedBox(height: mapType == MapTiles.vietmapVector ? 0 : 5),
          Text(mapType.value,
              style: TextStyle(
                  fontSize: 12,
                  color: mapType == currentMapType
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                  fontWeight: mapType == currentMapType
                      ? FontWeight.bold
                      : FontWeight.normal))
        ]),
      ),
    );
  }

  getMapTypeOptionsImage(MapTiles mapType) {
    return Image.asset(
      'assets/images/vietmap_vector.png',
      width: 60,
      height: 60,
    );
    switch (mapType) {
      case MapTiles.vietmapVector:
        return Image.asset(
          'assets/images/vietmap_vector.png',
          width: 60,
          height: 60,
        );
      case MapTiles.vietmapDarkMap:
        return Image.asset(
          'assets/images/vietmap_raster.png',
          width: 60,
          height: 60,
        );
      case MapTiles.vietmapTileMap:
        return Image.asset(
          'assets/images/google.png',
          width: 60,
          height: 60,
        );
      case MapTiles.vietmapRasterLM:
        return Image.asset(
          'assets/images/google_satellite.png',
          width: 60,
          height: 60,
        );
      default:
        return Image.asset(
          'assets/images/vietmap_raster.png',
          width: 60,
          height: 60,
        );
    }
  }
}
