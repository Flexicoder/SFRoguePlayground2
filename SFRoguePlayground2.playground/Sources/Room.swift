//
//  Room.swift
//  
//
//  Created by Paul Ledger on 22/04/2020.
//

import Foundation
import SpriteKit
import GameplayKit

public class Room: NSObject {
    var node: SKShapeNode   // Used to hold the "floor" of the room
    var number: Int         // Used to identify the room
    var cols: Int           // Number of columns the room is made up of
    var rows: Int           // Number of rows the room is made up of

    private let randomSource = GKRandomSource.sharedRandom()

    public init(number: Int) {
        self.number = number

        // Create a random number of columns and rows, based on restrictions.
        // Multiply the random number by 2 always ensures that we get an "even" sized room

        self.cols = Int.random(in: Constants.Constraints.minimumExtent..<Constants.Constraints.maximumExtent) * 2
        let width = Int(cols * Constants.Constraints.tileSize)
        self.rows = Int.random(in: Constants.Constraints.minimumExtent..<Constants.Constraints.maximumExtent) * 2
        let height = Int(rows * Constants.Constraints.tileSize)

        // Create a basic node using the size and fill it in so we can see it
        self.node = SKShapeNode(rectOf: CGSize(width: width, height: height))
        self.node.lineWidth = 0
        self.node.fillColor = .red
        self.node.name = "room\(self.number)"

        // A random position for the room
        let x = Int(Int.random(in: Constants.Constraints.minimumPositionOffset..<Constants.Constraints.maximumPositionOffset) * Constants.Constraints.tileSize)
        let y = Int(Int.random(in: Constants.Constraints.minimumPositionOffset..<Constants.Constraints.maximumPositionOffset) * Constants.Constraints.tileSize)

        self.node.position = CGPoint(x: x, y: y)

        // Create a basic node using the size reduced by 2 tile sizes in each direction
        let floor =  SKShapeNode(rectOf: CGSize(width: width - (Constants.Constraints.tileSize * 2), height: height - (Constants.Constraints.tileSize * 2)))
        floor.lineWidth = 0
        floor.fillColor = .black
        self.node.addChild(floor)
    }

    public func render(scene: SKScene) {
        scene.addChild(self.node)
    }

    var frame: CGRect {
        self.node.frame
    }

    var height: CGFloat {
        self.node.frame.height
    }

    var width: CGFloat {
        self.node.frame.width
    }

    public func moveTo(x: CGFloat = CGFloat.greatestFiniteMagnitude,
                       y: CGFloat = CGFloat.greatestFiniteMagnitude ) {
        // Using 'fixed' default values means we only need to
        // supply the values that need to change.
        // If the default value is detected then the existing value is used

        self.node.position = CGPoint(x: ( x == CGFloat.greatestFiniteMagnitude ? self.node.position.x : x ),
                                     y: ( y == CGFloat.greatestFiniteMagnitude ? self.node.position.y : y ))
    }

    public func removeOverlap(rooms: [Room]) -> Int {
        // Used to highlight that intersections were found
        var intersectionCount = 0

        // Pulling out values from the frame, for simplicity
        let thisFrame = self.frame
        let thisRoomBottom = thisFrame.minY
        let thisRoomTop = thisFrame.maxY
        let thisRoomLeft = thisFrame.minX
        let thisRoomRight = thisFrame.maxX

        for otherRoom in rooms {

            if thisFrame.intersects(otherRoom.frame) {
                // Check the frames and if they intersect the otherRoom needs to move

                intersectionCount += 1

                // In order to keep the "randomness" of the rooms,
                // we calculate new X and Y positions based on this rooms position.
                // Using the nextBool function we can get varying layouts

                // The height and width are halved because the anchor point is in the centre of the room

                let newY = randomSource.nextBool()
                    ? thisRoomBottom - (otherRoom.height / 2)
                    : thisRoomTop + (otherRoom.height / 2)

                let newX =  randomSource.nextBool()
                    ? thisRoomLeft - (otherRoom.width / 2)
                    : thisRoomRight + (otherRoom.width / 2)

                //Randomly pick which way to move the room
                if randomSource.nextBool() {
                    otherRoom.moveTo(y: newY)
                } else {
                    otherRoom.moveTo(x: newX)
                }

                if self.frame.intersects(otherRoom.frame) {
                    // they are still intersecting so change both values
                    otherRoom.moveTo(x: newX, y: newY)
                }
            }
        }

        return intersectionCount
    }
}
