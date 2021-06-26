//
//  File.swift
//  
//
//  Created by Michael Helmbrecht on 26.06.21.
//
import Foundation
import MapKit
import CoreLocation

public struct Route: Identifiable {
  public let id: String
  public let name: String?
  public let distance: Double
  public let estimatedTime: Double
  public let waypoints: [Coordinate]
  public let steps: [Step]
  
  internal init(id: String = UUID().uuidString, name: String?, distance: Double, estimatedTime: Double, waypoints: [Coordinate], steps: [Step]) {
    self.id = id
    self.name = name
    self.distance = distance
    self.estimatedTime = estimatedTime
    self.waypoints = waypoints
    self.steps = steps
  }
}

public enum TurnType: String{
  case left, right, straight, unknown
}

public struct Step: Identifiable{
  public let id: String = UUID().uuidString
  public let distance: Double
  public let turnType: TurnType
  public let waypoints: [Coordinate]
  public let bearing: Double
}


public struct RouteSegment: Identifiable, Codable {
  public let id: String
  public let node1: RouteNode
  public let node2: RouteNode
  
  public let intermediatePoints: [Coordinate]
  
  public init(id: String = UUID().uuidString,
              node1: RouteNode,
              node2: RouteNode,
              intermediatePoints: [Coordinate] = []) {
    self.id = id
    self.node1 = node1
    self.node2 = node2
    self.intermediatePoints = intermediatePoints
    
  }
}

public struct RouteNode: Identifiable, Codable{
  public let id: String
  public let coordinate: Coordinate
  
  public init(id: String = UUID().uuidString, coordinate: Coordinate){
    self.id = id
    self.coordinate = coordinate
  }
}


public struct Coordinate: Codable, Equatable {
  public let latitude: Double
  public let longitude: Double
  
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}
