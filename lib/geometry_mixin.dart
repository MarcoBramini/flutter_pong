import 'dart:math';
import 'dart:ui';

enum RectCollisionArea {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left
}

class GeometryMixin {
  bool isCircleWithinVerticalRange(double circleXOffset, double circleRadius,
          double boundary1XOffset, double boundary2XOffset) =>
      circleXOffset - circleRadius >= boundary1XOffset &&
      circleXOffset + circleRadius <= boundary2XOffset;

  bool isPointAboveHorizontalLine(double pointYOffset, double lineYOffset) =>
      pointYOffset > lineYOffset;

  bool isCircleBelowHorizontalLine(
          double circleYOffset, double circleRadius, double lineYOffset) =>
      circleYOffset + circleRadius < lineYOffset;

  bool isCircleAboveHorizontalLine(
          double circleYOffset, double circleRadius, double lineYOffset) =>
      circleYOffset - circleRadius > lineYOffset;

  bool isPointWithinRect(double pointX, double pointY, double rectXOffset,
          double rectYOffset, double rectHeight, double rectWidth) =>
      pointY >= rectYOffset &&
      pointY <= rectYOffset + rectHeight &&
      pointX >= rectXOffset &&
      pointX <= rectXOffset + rectWidth;

  RectCollisionArea detectCircleRectCollision(
      Offset circleOffset,
      double circleRadius,
      Offset rectOffset,
      double rectHeight,
      double rectWidth) {
    List<Offset> samplePoints = calculateCircleCollisionDetectionSamplePoints(
        circleOffset, circleRadius);

    for (Offset p in samplePoints) {
      if (isPointWithinRect(
          p.dx, p.dy, rectOffset.dx, rectOffset.dy, rectHeight, rectWidth)) {
        return calculateRectCollisionArea(
            p.dx, p.dy, rectOffset, rectHeight, rectWidth);
      }
    }
    return null;
  }

  List<Offset> calculateCircleCollisionDetectionSamplePoints(
      Offset circleOffset, double circleRadius) {
    List<Offset> samplePoints = new List<Offset>();

    for (double i = 0; i < 2 * pi; i += pi / 4) {
      Offset p = Offset(
        circleOffset.dx + (circleRadius * sin(i)),
        circleOffset.dy + (circleRadius * cos(i)),
      );
      samplePoints.add(p);
    }

    return samplePoints;
  }

  RectCollisionArea calculateRectCollisionArea(double pointX, double pointY,
      Offset rectOffset, double rectHeight, double rectWidth) {
    List<Offset> topSamplePoints = new List<Offset>();
    List<Offset> bottomSamplePoints = new List<Offset>();
    for (int i = 1; i < (rectWidth ~/ 10); i++) {
      topSamplePoints
          .add(Offset(rectOffset.dx + ((rectWidth / 10) * i), rectOffset.dy));
      bottomSamplePoints.add(Offset(
          rectOffset.dx + (rectWidth / 10) * i, rectOffset.dy + rectHeight));
    }

    Map<RectCollisionArea, List<Offset>> samplePoints = {
      RectCollisionArea.top: topSamplePoints,
      RectCollisionArea.topRight: [
        Offset(rectOffset.dx + rectWidth, rectOffset.dy)
      ],
      RectCollisionArea.right: [
        Offset(rectOffset.dx + rectWidth, rectOffset.dy + (rectHeight / 2))
      ],
      RectCollisionArea.bottomRight: [
        Offset(rectOffset.dx + rectWidth, rectOffset.dy + rectHeight)
      ],
      RectCollisionArea.bottom: bottomSamplePoints,
      RectCollisionArea.bottomLeft: [
        Offset(rectOffset.dx, rectOffset.dy + rectHeight)
      ],
      RectCollisionArea.left: [
        Offset(rectOffset.dx, rectOffset.dy + (rectHeight / 2))
      ],
      RectCollisionArea.topLeft: [Offset(rectOffset.dx, rectOffset.dy)],
    };

    RectCollisionArea minDistanceArea;
    double minDistance = 100000;
    samplePoints.forEach((RectCollisionArea rca, List<Offset> offsetList) {
      offsetList.forEach((Offset o) {
        double distance =
            calculateDistanceBetweenPoints(pointX, pointY, o.dx, o.dy);
        if (distance < minDistance) {
          minDistanceArea = rca;
          minDistance = distance;
        }
      });
    });
    return minDistanceArea;
  }

  double calculateDistanceBetweenPoints(
          double x1, double y1, double x2, double y2) =>
      sqrt(pow((x1 - x2), 2) + pow((y1 - y2), 2));
}
