import math

def calculate_angle(a, b, c):
    """
    Calculate the angle between three points (a, b, c).
    Each point is a landmark with x, y coordinates.
    """
    radians = math.atan2(c.y - b.y, c.x - b.x) - math.atan2(a.y - b.y, a.x - b.x)
    angle = abs(radians * 180.0 / math.pi)
    return angle