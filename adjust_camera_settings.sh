#!/bin/bash
# Quick RealSense D455 Settings Adjustment
# Run this while the camera is streaming to test different settings

CAMERA_NODE="/camera/realsense2_camera_node"

echo "=== RealSense D455 Live Settings Adjustment ==="
echo ""

# Function to show current value
show_setting() {
    local param=$1
    local value=$(ros2 param get $CAMERA_NODE $param 2>/dev/null | grep -oP '(?<=is: ).*')
    echo "  Current $param: $value"
}

# Check if camera node is running
if ! ros2 node list | grep -q "realsense2_camera_node"; then
    echo "ERROR: RealSense camera node is not running!"
    echo "Start it first with: ros2 launch d455_unity_streaming.launch.py"
    exit 1
fi

echo "Camera node found. Current settings:"
echo ""
show_setting "depth_module.emitter_enabled"
show_setting "depth_module.laser_power"
show_setting "hole_filling_filter.enable"
show_setting "hole_filling_filter.mode"
show_setting "spatial_filter.enable"
show_setting "temporal_filter.enable"

echo ""
echo "=== Quick Adjustments ==="
echo ""

# Menu
PS3='Choose an option (or 0 to exit): '
options=(
    "Enable/Toggle Emitter (laser projector)"
    "Increase Laser Power (+50)"
    "Decrease Laser Power (-50)"
    "Set Laser Power to Max (360)"
    "Enable Hole Filling Filter"
    "Change Hole Filling Mode"
    "Enable All Depth Filters"
    "Disable All Depth Filters"
    "Show All Current Settings"
)

select opt in "${options[@]}"
do
    case $opt in
        "Enable/Toggle Emitter (laser projector)")
            current=$(ros2 param get $CAMERA_NODE depth_module.emitter_enabled | grep -oP '\d+')
            if [ "$current" = "1" ]; then
                echo "Turning emitter OFF..."
                ros2 param set $CAMERA_NODE depth_module.emitter_enabled 0
            else
                echo "Turning emitter ON..."
                ros2 param set $CAMERA_NODE depth_module.emitter_enabled 1
            fi
            show_setting "depth_module.emitter_enabled"
            ;;
        "Increase Laser Power (+50)")
            current=$(ros2 param get $CAMERA_NODE depth_module.laser_power | grep -oP '\d+')
            new=$((current + 50))
            if [ $new -gt 360 ]; then new=360; fi
            echo "Setting laser power to $new..."
            ros2 param set $CAMERA_NODE depth_module.laser_power $new
            show_setting "depth_module.laser_power"
            ;;
        "Decrease Laser Power (-50)")
            current=$(ros2 param get $CAMERA_NODE depth_module.laser_power | grep -oP '\d+')
            new=$((current - 50))
            if [ $new -lt 0 ]; then new=0; fi
            echo "Setting laser power to $new..."
            ros2 param set $CAMERA_NODE depth_module.laser_power $new
            show_setting "depth_module.laser_power"
            ;;
        "Set Laser Power to Max (360)")
            echo "Setting laser power to maximum (360)..."
            ros2 param set $CAMERA_NODE depth_module.laser_power 360
            show_setting "depth_module.laser_power"
            ;;
        "Enable Hole Filling Filter")
            echo "Enabling hole filling filter..."
            ros2 param set $CAMERA_NODE hole_filling_filter.enable true
            show_setting "hole_filling_filter.enable"
            ;;
        "Change Hole Filling Mode")
            echo "Hole Filling Modes:"
            echo "  0 = fill_from_left"
            echo "  1 = farthest_from_around (best for arms/humans)"
            echo "  2 = nearest_from_around (best for flat surfaces)"
            read -p "Enter mode (0-2): " mode
            echo "Setting hole filling mode to $mode..."
            ros2 param set $CAMERA_NODE hole_filling_filter.mode $mode
            show_setting "hole_filling_filter.mode"
            ;;
        "Enable All Depth Filters")
            echo "Enabling all depth filters (recommended)..."
            ros2 param set $CAMERA_NODE spatial_filter.enable true
            ros2 param set $CAMERA_NODE temporal_filter.enable true
            ros2 param set $CAMERA_NODE hole_filling_filter.enable true
            ros2 param set $CAMERA_NODE disparity_filter.enable true
            echo "All filters enabled!"
            ;;
        "Disable All Depth Filters")
            echo "Disabling all depth filters..."
            ros2 param set $CAMERA_NODE spatial_filter.enable false
            ros2 param set $CAMERA_NODE temporal_filter.enable false
            ros2 param set $CAMERA_NODE hole_filling_filter.enable false
            ros2 param set $CAMERA_NODE disparity_filter.enable false
            echo "All filters disabled!"
            ;;
        "Show All Current Settings")
            echo ""
            echo "=== All RealSense Settings ==="
            ros2 param list $CAMERA_NODE
            echo ""
            echo "To see a specific value: ros2 param get $CAMERA_NODE <param_name>"
            ;;
        *) 
            echo "Exiting..."
            exit 0
            ;;
    esac
    echo ""
    echo "Press Enter to continue..."
    read
done
