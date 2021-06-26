


import Foundation
//import MapKit
import CoreLocation
import NeoGeoLibrary
import Algorithms


extension Coordinate {
  func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  func toCLLocation() -> CLLocation {
    CLLocation(latitude: latitude, longitude: longitude)
  }
}


class ACRoutingService{
  
  static func createRoute(from segments: [RouteSegment]) -> Route{
    checkForSegmentIntegrity(segments: segments)
    let allSegmentCoordinates = segments
      .flatMap { segment in
        return [segment.node1.coordinate] + segment.intermediatePoints + [segment.node2.coordinate]
      }
    let distance = calculateDistance(from: allSegmentCoordinates)
    let estimatedTime = calculateEstimatedTime(from: distance)
    let steps = createSteps(from: segments)
    return Route(distance: distance, estimatedTime: estimatedTime, waypoints: allSegmentCoordinates, steps: steps)
  }
  
  private static func calculateDistance(from coordinates: [Coordinate]) -> Double {
    var distance: Double = 0
    for (coordinate, nextCoordinate) in coordinates.adjacentPairs() {
      distance += coordinate.toCLLocation().distance(from: nextCoordinate.toCLLocation())
    }
    return coordinates.adjacentPairs().reduce(0) { result, coordinateTouple in
      coordinateTouple.0.toCLLocation().distance(from: coordinateTouple.1.toCLLocation())
    }
  }
  
  private static func calculateEstimatedTime(from distance: Double) -> Double {
    distance / 7000 * 60 //7km/h speed
  }
  
  private static func createSteps(from segments: [RouteSegment]) -> [Step] {
    var steps: [Step] = []
    
    for (segment, nextSegment) in segments.adjacentPairs() {
      //construct waypoints
      let waypoints =  [segment.node1.coordinate] + segment.intermediatePoints + [segment.node2.coordinate]
      //calulate complete step distance
      let distance = calculateDistance(from: waypoints)
      //Calculate turn type
      let startCoordinate = segment.intermediatePoints.last ?? segment.node1.coordinate
      let centerCoordinate = segment.node2.coordinate
      let destinationCoordinate = nextSegment.intermediatePoints.first ?? segment.node2.coordinate
      let turnType = calculateTurnType(startCoordinate: startCoordinate, centerCoordinate: centerCoordinate, destinationCoordinate: destinationCoordinate)
      //caluclate bearing for last segment part to rotate marker on map
      let bearing = startCoordinate.toCLLocationCoordinate2D().bearingTo(centerCoordinate.toCLLocationCoordinate2D())
      //append step to steps
      steps.append(Step(distance: distance, turnType: turnType, waypoints: waypoints, bearing: bearing))
    }
    
    return steps
  }
  
  private static func checkForSegmentIntegrity(segments: [RouteSegment]){
    var firstNodes = segments.map{$0.node1}
    var secondNodes = segments.map{$0.node2}
    firstNodes.removeFirst()
    secondNodes.removeLast()
    
    if product(firstNodes, secondNodes).map({ $0.0.coordinate == $0.1.coordinate}).contains(false) {
      fatalError("nodes are not connected")
    }
  }
  
  private static func calculateTurnType(startCoordinate: Coordinate, centerCoordinate: Coordinate, destinationCoordinate: Coordinate) -> TurnType {
    let degree = NGHelper.calculateDegreeAngle(startCoordinate: startCoordinate.toCLLocationCoordinate2D(),
                                               centerCoordinate: centerCoordinate.toCLLocationCoordinate2D(),
                                               destinationCoordinate: destinationCoordinate.toCLLocationCoordinate2D())
    switch degree {
    case 80...100:
      return .left
    case (-100)...(-80):
      return .right
    case -30...30:
      return .straight
    default:
      return .unknown
    }
    
  }
}
