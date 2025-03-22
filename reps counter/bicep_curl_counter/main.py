import cv2
from pose_estimator import PoseEstimator
from rep_counter import RepCounter
from utils import calculate_angle

# Initialize components
pose_estimator = PoseEstimator()
rep_counter = RepCounter()

# Open the video file
video_path = "video/bicep_curl_video.mp4"
cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print(f"Error: Could not open video file '{video_path}'")
    exit()

# Get video properties
frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = cap.get(cv2.CAP_PROP_FPS)

# Define the codec and create VideoWriter object
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
output_path = "output/bicep_curl_output.mp4"
out = cv2.VideoWriter(output_path, fourcc, fps, (frame_width, frame_height))

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break  # Exit the loop when there are no more frames

    results, annotated_frame = pose_estimator.process_frame(frame)

    if results.pose_landmarks:
        landmarks = results.pose_landmarks.landmark

        # Extract keypoints for the left arm
        left_shoulder = landmarks[11]  # Left shoulder
        left_elbow = landmarks[13]     # Left elbow
        left_wrist = landmarks[15]     # Left wrist

        # Extract keypoints for the right arm
        right_shoulder = landmarks[12]  # Right shoulder
        right_elbow = landmarks[14]     # Right elbow
        right_wrist = landmarks[16]     # Right wrist

        # Calculate angles for both arms
        left_angle = calculate_angle(left_shoulder, left_elbow, left_wrist)
        right_angle = calculate_angle(right_shoulder, right_elbow, right_wrist)

        # Print angles for debugging
        print(f"Left Angle: {left_angle:.2f}, Right Angle: {right_angle:.2f}")

        # Update the repetition counter
        rep_counter.update(left_angle, right_angle)

        # Display the angles and rep counts on the frame
        cv2.putText(
            annotated_frame,
            f"Left Angle: {left_angle:.2f}",
            (50, 50),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 255, 0),
            2,
        )
        cv2.putText(
            annotated_frame,
            f"Right Angle: {right_angle:.2f}",
            (50, 80),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 255, 0),
            2,
        )
        cv2.putText(
            annotated_frame,
            f"Left Reps: {rep_counter.get_left_reps()}",
            (50, 110),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 255, 0),
            2,
        )
        cv2.putText(
            annotated_frame,
            f"Right Reps: {rep_counter.get_right_reps()}",
            (50, 140),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 255, 0),
            2,
        )

    # Write the annotated frame to the output video
    out.write(annotated_frame)

    # Display the annotated frame
    cv2.imshow("Bicep Curl Counter", annotated_frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break  # Exit the loop if 'q' is pressed

# Release resources
cap.release()
out.release()
cv2.destroyAllWindows()

print(f"Total Left Reps: {rep_counter.get_left_reps()}")
print(f"Total Right Reps: {rep_counter.get_right_reps()}")
print(f"Total Reps: {rep_counter.get_total_reps()}")