class RepCounter:
    def __init__(self, extended_threshold=170, curled_threshold=75):
        self.left_reps = 0
        self.right_reps = 0
        self.left_state = "extended"
        self.right_state = "extended"
        self.extended_threshold = extended_threshold
        self.curled_threshold = curled_threshold

    def update(self, left_angle, right_angle):
        """
        Update the state based on the current angles and count repetitions.
        """
        # Update left arm state
        if self.left_state == "extended" and left_angle < self.curled_threshold:
            self.left_state = "curled"
        elif self.left_state == "curled" and left_angle > self.extended_threshold:
            self.left_state = "extended"
            self.left_reps += 1

        # Update right arm state
        if self.right_state == "extended" and right_angle < self.curled_threshold:
            self.right_state = "curled"
        elif self.right_state == "curled" and right_angle > self.extended_threshold:
            self.right_state = "extended"
            self.right_reps += 1

    def get_left_reps(self):
        return self.left_reps

    def get_right_reps(self):
        return self.right_reps

    def get_total_reps(self):
        return self.left_reps + self.right_reps