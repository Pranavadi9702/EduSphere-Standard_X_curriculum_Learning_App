from flask import Flask, render_template_string
import folium
import geopandas as gpd
from shapely.geometry import box
from shapely.ops import unary_union
from folium.features import DivIcon
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)

# Load GeoJSON
india_geojson = "india_geojson.geojson"
gdf_india = gpd.read_file(india_geojson)
gdf_india = gdf_india.drop(columns=["created_at", "updated_at"], errors="ignore")

# with open("india_state_info.json", "r", encoding="utf-8") as f:
#     state_info = json.load(f)

# Ensure the correct column name for state names
if "name" not in gdf_india.columns:
    raise ValueError("The GeoJSON file does not have a 'name' column.")

# Convert FeatureCollection to MultiPolygon
india_geom = unary_union(gdf_india.geometry)

@app.route("/")
def map_view():
    # Create a base map
    m = folium.Map(location=[18, 84], zoom_start=5, min_zoom=5, tiles=None, control_scale=True)

    # Create a world mask excluding India
    world_bounds = box(-180, -90, 180, 90)
    mask = gpd.GeoDataFrame(geometry=[world_bounds], crs="EPSG:4326")
    mask = mask.overlay(gpd.GeoDataFrame(geometry=[india_geom], crs="EPSG:4326"), how="difference")

    folium.GeoJson(
        mask,
        name="World Mask",
        style_function=lambda feature: {
            "fillColor": "white",
            "color": "white",
            "weight": 0,
            "fillOpacity": 0.7
        },
    ).add_to(m)

    # Add India GeoJSON layer
    geojson_layer = folium.GeoJson(
        gdf_india,
        name="India",
        style_function=lambda feature: {
            "fillColor": "none",
            "color": "black",
            "weight": 1,
            "fillOpacity": 0.1  # Make the state clickable while remaining invisible
        },
        highlight_function=None,  # Disable hover highlight
    )
    geojson_layer.add_to(m)

    # Add state labels
    state_label_layer = folium.FeatureGroup(name="State Labels", control=False)
    for _, row in gdf_india.iterrows():
        centroid = row["geometry"].centroid  # Get the state's center
        folium.Marker(
            location=[centroid.y, centroid.x],
            icon=DivIcon(
                icon_size=(150, 36),
                icon_anchor=(75, 18),
                html=f'<div class="state-label" style="font-size:12px; font-weight:bold; color:black; background:none; padding:2px; border-radius:3px; text-align:center; pointer-events:none;">{row["name"]}</div>',
            ),
        ).add_to(state_label_layer)
    state_label_layer.add_to(m)

    # ✅ OpenStreetMap as Default (First Layer)
    folium.TileLayer(
        tiles='CartoDB Voyager',
        name='Political Map',
        attr='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
        min_zoom = 5
    ).add_to(m)

    folium.TileLayer(
        tiles="https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
        name="Physical Map",
        attr="&copy; OpenTopoMap, SRTM, NASA, OpenStreetMap contributors",
        min_zoom=5
    ).add_to(m)

    folium.TileLayer(
        tiles="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        name="Default Map",  # ✅ Make sure this is the default
        attr='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        min_zoom=5
    ).add_to(m)  # ✅ First layer is always the default

    # ✅ Add Layer Control for Switching
    folium.LayerControl().add_to(m)


    return render_template_string("""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>India Map</title>
    
    <!-- Include Leaflet -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>

    <style> 

        
        .state-label {
        pointer-events: none; /* Allow clicks to pass through */
        position: absolute;
        font-size: 14px;
        font-weight: bold;
        background: none;
        padding: 2px;
        border-radius: 3px;
        text-align: center;
        color: black;
        
        html, body { height: 100%; margin: 0; padding: 0; overflow: hidden; }
        #map-container { width: 100vw; height: 100vh; position: absolute; top: 0; left: 0; }
        
    </style>
</head>
<body>
    <div id="map-container">
        {{ map_html|safe }}  <!-- Ensure Folium map is embedded -->
    </div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ Page loaded, checking for map container...");

    var foliumIframe = document.querySelector("iframe");

    if (!foliumIframe) {
        console.error("❌ Folium map iframe not found.");
        return;
    }

    console.log("✅ Folium map iframe detected.");

    foliumIframe.onload = function () {
        setTimeout(function () {
            var iframeWindow = foliumIframe.contentWindow;
            var iframeDocument = foliumIframe.contentDocument || iframeWindow.document;

            if (!iframeWindow.L) {
                console.error("❌ Leaflet library not found in iframe.");
                return;
            }

            console.log("✅ Leaflet library detected in iframe.");

            var mapContainer = iframeDocument.querySelector(".leaflet-container");
            if (!mapContainer) {
                console.error("❌ Leaflet map container not found.");
                return;
            }

            console.log("✅ Leaflet map container detected.");

            var map;
            for (var key in iframeWindow) {
                if (iframeWindow[key] instanceof iframeWindow.L.Map) {
                    map = iframeWindow[key];
                    break;
                }
            }

            if (!map) {
                console.error("❌ Leaflet map instance not found.");
                return;
            }

            console.log("✅ Leaflet map detected.");

            // ✅ **Disable double-click zoom**
            map.options.doubleClickZoom = false;
            map.doubleClickZoom.disable();
            console.log("✅ Disabled double-click zoom.");

            // ✅ **Disable double-tap zoom on mobile**
            map.options.touchZoom = true; // Keep touch zoom
            map.options.tap = false; // Disable double-tap zoom
            console.log("✅ Disabled double-tap zoom.");

            // ✅ **Set minZoom globally**
            map.eachLayer(function (layer) {
                if (layer instanceof iframeWindow.L.TileLayer) {
                    layer.options.minZoom = 5;
                }
            });
            map.setMinZoom(5);
            console.log("✅ Enforced minZoom=5 on all tile layers.");

            var geojsonLayer;
            map.eachLayer(function (layer) {
                if (layer instanceof iframeWindow.L.GeoJSON) {
                    geojsonLayer = layer;
                }
            });

            if (!geojsonLayer) {
                console.error("❌ GeoJSON layer not found.");
                return;
            }

            console.log("✅ GeoJSON layer detected.");

            var selectedLayer = null;
            var selectedLayerId = null;

            function upliftState(e) {
                var clickedLayer = e.target;
                var stateName = clickedLayer.feature.properties.name;
                console.log("✅ Clicked on:", stateName);

                var currentLayerId = clickedLayer._leaflet_id;

                if (selectedLayerId === currentLayerId) {
                    console.log("✅ Deselected:", stateName);
                    resetAllStates();
                    selectedLayer = null;
                    selectedLayerId = null;
                    return;
                }

                resetAllStates();

                clickedLayer.setStyle({
                    fillColor: "rgba(0, 0, 0, 0.1)",
                    weight: 3,
                    fillOpacity: 0.4,
                    color: "black",
                    shadowBlur: 20
                });

                var bounds = clickedLayer.getBounds();

                map.fitBounds(bounds, {
                    padding: [50, 50],
                    maxZoom: 7,
                    animate: true
                });

                selectedLayer = clickedLayer;
                selectedLayerId = currentLayerId;
            }

            function resetAllStates() {
                geojsonLayer.eachLayer(function (layer) {
                    layer.setStyle({
                        fillColor: "#8F8E8EFF",
                        color: "black",
                        weight: 1.5,
                        fillOpacity: 0.4
                    });
                });
            }

            function attachClickEvents() {
                geojsonLayer.eachLayer(function (layer) {
                    layer.options.interactive = true;
                    layer.setStyle({
                        weight: 1,
                        color: "black",
                        fillOpacity: 0.4,
                        fillColor: "rgba(0, 0, 0, 0.1)",
                        cursor: "pointer"
                    });

                    layer.off("click").off("tap").off("touchstart");

                    // ✅ Attach click & tap events for all devices
                    layer.on("click", upliftState);
                    layer.on("tap", upliftState);
                    
                    // ✅ Add touch event listeners for mobile
                    layer.on("touchstart", function (e) {
                        upliftState(e);
                        e.preventDefault(); // Prevent default scrolling
                    });

                    layer.on("touchend", function (e) {
                        e.preventDefault(); // Stop unintended zooming
                    });
                });

                console.log("✅ Click and touch events attached.");
            }

            attachClickEvents();

            map.on("zoomend moveend", function () {
                console.log("🔄 Reapplying highlight after zoom/move...");
                if (selectedLayer) {
                    selectedLayer.setStyle({
                        fillColor: "rgba(0, 0, 0, 0.1)",
                        weight: 3,
                        fillOpacity: 0.4,
                        color: "black",
                        shadowBlur: 20
                    });
                }
            });

            // ✅ Improve mobile view
            if (window.innerWidth < 768) {
                var mapIframe = document.querySelector("iframe");
                if (mapIframe) {
                    mapIframe.style.height = "100vh";
                    mapIframe.style.width = "100vw";
                }
            }
        }, 2000);
    };
    if (window.innerWidth < 768) {
        var mapIframe = document.querySelector("iframe");
        if (mapIframe) {
            mapIframe.style.height = "100vh";
            mapIframe.style.width = "100vw";
        }
    }
});

</script>                        

</body>
</html>
""", map_html=m._repr_html_())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True)  # Running on port 5002
