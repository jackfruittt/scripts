#!/bin/bash
# Publish position commands to UR3 using ROS2 actions

set -e

# Default joint positions (in radians)
DEFAULT_J1="1.0"
DEFAULT_J2="-1.57"
DEFAULT_J3="0.0"
DEFAULT_J4="-1.57"
DEFAULT_J5="0.0"
DEFAULT_J6="0.0"

# Check if positions provided as command-line arguments
if [ $# -eq 6 ]; then
    # Validate that all arguments are numbers
    if [[ "$1" =~ ^-?[0-9]+\.?[0-9]*$ ]] && \
       [[ "$2" =~ ^-?[0-9]+\.?[0-9]*$ ]] && \
       [[ "$3" =~ ^-?[0-9]+\.?[0-9]*$ ]] && \
       [[ "$4" =~ ^-?[0-9]+\.?[0-9]*$ ]] && \
       [[ "$5" =~ ^-?[0-9]+\.?[0-9]*$ ]] && \
       [[ "$6" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
        J1="$1"
        J2="$2"
        J3="$3"
        J4="$4"
        J5="$5"
        J6="$6"
        echo "Using command-line joint positions..."
    else
        echo "Warning: Invalid joint values provided. Using defaults."
        J1="$DEFAULT_J1"
        J2="$DEFAULT_J2"
        J3="$DEFAULT_J3"
        J4="$DEFAULT_J4"
        J5="$DEFAULT_J5"
        J6="$DEFAULT_J6"
    fi
elif [ $# -eq 0 ]; then
    # No arguments, use environment variables or defaults
    J1=${J1:-"$DEFAULT_J1"}
    J2=${J2:-"$DEFAULT_J2"}
    J3=${J3:-"$DEFAULT_J3"}
    J4=${J4:-"$DEFAULT_J4"}
    J5=${J5:-"$DEFAULT_J5"}
    J6=${J6:-"$DEFAULT_J6"}
    echo "Using default/environment joint positions..."
else
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 [J1 J2 J3 J4 J5 J6]"
    echo "Example: $0 0.0 -1.57 0.0 -1.57 0.0 0.0"
    echo "Or use environment variables: J1=0.0 J2=-1.57 $0"
    echo "Or run with no arguments to use defaults: [$DEFAULT_J1, $DEFAULT_J2, $DEFAULT_J3, $DEFAULT_J4, $DEFAULT_J5, $DEFAULT_J6]"
    exit 1
fi

echo "Publishing UR3 Joint Position..."
echo "Joint positions: [$J1, $J2, $J3, $J4, $J5, $J6]"

# Source ROS2
if [ -f "/opt/ros/humble/setup.bash" ]; then
    source /opt/ros/humble/setup.bash
elif [ -f "/opt/ros/jazzy/setup.bash" ]; then
    source /opt/ros/jazzy/setup.bash
else
    echo "Error: No ROS2 installation found"
    exit 1
fi

# Source workspace
if [ -f "$HOME/ros2_ws/install/setup.bash" ]; then
    source ~/ros2_ws/install/setup.bash
fi

# Send joint trajectory goal via action
ros2 action send_goal /scaled_joint_trajectory_controller/follow_joint_trajectory \
    control_msgs/action/FollowJointTrajectory \
    "{
        trajectory: {
            joint_names: [shoulder_pan_joint, shoulder_lift_joint, elbow_joint, wrist_1_joint, wrist_2_joint, wrist_3_joint],
            points: [
                {
                    positions: [$J1, $J2, $J3, $J4, $J5, $J6],
                    time_from_start: {sec: 2, nanosec: 0}
                }
            ]
        }
    }"
