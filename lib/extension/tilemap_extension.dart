import 'package:vietmap_map/features/map_screen/components/select_map_tiles_modal.dart';

extension TileMapExtension on MapTiles {
  String getMapTiles(String apiKey) {
    assert(apiKey.isNotEmpty);
    switch (this) {
      case MapTiles.vietmapVector:
        return "https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=$apiKey";
      case MapTiles.vietmapDarkMap:
        return "https://maps.vietmap.vn/maps/styles/dm/style.json?apikey=$apiKey";
      case MapTiles.vietmapTileMap:
        return "https://maps.vietmap.vn/maps/styles/lm/style.json?apikey=$apiKey";
      case MapTiles.vietmapRasterLM:
        return """{
      version: 8,
      sources: {
        raster_vm: {
          type: "raster",
          tiles: [
            `https://maps.vietmap.vn/api/lm/{z}/{x}/{y}@2x.png?apikey=${apiKey}`,
          ],
          tileSize: 256,
          attribution: "Vietmap@copyright",
        }
      },
      layers: [
        {
          id: "layer_raster_vm",
          type: "raster",
          source: "raster_vm",
          minzoom: 0,
          maxzoom: 20,
        },
      ],
    }""";
      case MapTiles.vietmapRasterDM:
        return """{
      version: 8,
      sources: {
        raster_vm: {
          type: "raster",
          tiles: [
            `https://maps.vietmap.vn/api/maps/raster/dm/{z}/{x}/{y}@2x.png?apikey=${apiKey}`,
          ],
          tileSize: 256,
          attribution: "Vietmap@copyright",
        }
      },
      layers: [
        {
          id: "layer_raster_vm",
          type: "raster",
          source: "raster_vm",
          minzoom: 0,
          maxzoom: 20,
        },
      ],
    }""";

      case MapTiles.vietmapRasterTile:
        return """{
      version: 8,
      sources: {
        raster_vm: {
          type: "raster",
          tiles: [
            `https://maps.vietmap.vn/api/maps/raster/tm/{z}/{x}/{y}@2x.png?apikey=${apiKey}`,
          ],
          tileSize: 256,
          attribution: "Vietmap@copyright",
        },

      },
      layers: [
        {
          id: "layer_raster_vm",
          type: "raster",
          source: "raster_vm",
          minzoom: 0,
          maxzoom: 20,
        },
      ],
    }""";
    }
  }
}
