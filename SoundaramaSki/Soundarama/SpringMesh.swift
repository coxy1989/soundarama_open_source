//
//  SpringMesh.swift
//  Soundarama
//
//  Created by George Keenan on 05/02/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/*
import Foundation
import Accelerate

//Outline of method here: https://cs.nyu.edu/~dzorin/numcomp08/springs_notes.pdf

func invert(matrix : [Double]) -> [Double] {
    var inMatrix:[Double]       = matrix
    // Get the dimensions of the matrix. An NxN matrix has N^2
    // elements, so sqrt( N^2 ) will return N, the dimension
    var N:__CLPK_integer        = __CLPK_integer( sqrt( Double( matrix.count ) ) )
    // Initialize some arrays for the dgetrf_(), and dgetri_() functions
    var pivots:[__CLPK_integer] = [__CLPK_integer](count: Int(N), repeatedValue: 0)
    var workspace:[Double]      = [Double](count: Int(N), repeatedValue: 0.0)
    var error: __CLPK_integer   = 0
    // Perform LU factorization
    dgetrf_(&N, &N, &inMatrix, &N, &pivots, &error)
    // Calculate inverse from LU factorization
    dgetri_(&N, &inMatrix, &N, &pivots, &workspace, &N, &error)
    return inMatrix
}

func multiplyMatrixByVector(matrix: [Double], vector: [Double])->[Double] {
    //Assume square matrix with same number of rows as vector
    var resultMatrix = [Double](count: vector.count, repeatedValue: 0.0)
    for i in 0..<vector.count {
        for j in 0..<vector.count {
            resultMatrix[i] += matrix[(vector.count*i)+j]*vector[j]
        }
    }
    return resultMatrix
}

func multiplyVectorByScalar(vector: [Double], scalar: Double)->[Double] {
    var s = scalar
    var vsresult = [Double](count : vector.count, repeatedValue : 0.0)
    vDSP_vsmulD(vector, 1, &s, &vsresult, 1, vDSP_Length(vector.count))
    return vsresult
}

func distanceBetweenPoints(p1: [Double], p2: [Double])->Double {
    return sqrt(pow(p1[0]-p2[0],2)+pow(p1[1]-p2[1],2))
}

func sumTwoByTwoMatricies (matrix1: [[Double]], matrix2: [[Double]])->[[Double]] {
    return [[matrix1[0][0]+matrix2[0][0],matrix1[0][1]+matrix2[0][1]],[matrix1[1][0]+matrix2[1][0],matrix1[1][1]+matrix2[1][1]]]
}

//specify connections
//let connections = [[0,1,0,0,0,1,0,1,0,1],[1,0,0,1,1,1,0,0,0,0],[0,0,0,1,1,0,0,0,1,0],[0,1,1,0,1,0,0,0,0,0],[0,1,1,1,0,1,0,0,0,0],[1,1,0,0,1,0,1,0,0,0],[0,0,0,0,0,1,0,0,0,0],[1,0,0,0,0,0,0,0,0,0],[0,0,1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0,0,0]]
//let connections = [[0,1,1,0],[1,0,0,1],[1,0,0,0],[0,1,0,0]]
let connections = [[0,1,1,1,0,0],[1,0,0,0,1,1],[1,0,0,0,0,0],[1,0,0,0,0,0],[0,1,0,0,0,0],[0,1,0,0,0,0]]
//let connections = [[0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0],[1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0],[0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0],[0,0,0,0,0,0,1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],[0,0,0,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],[0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0,0],[0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,0,0,0,1,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0],[1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0],[0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]



//var allPoints = [0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5, 0.6, 0.6, 0, 4.5, 2.5, 1, 5, 5, 0, 0]
//var allPoints = [1.1, 5.0, 2.0, 2.0, 0.0, 0.0, 3.0, 3.0]
var allPoints = [20.0,2.0,2.1,2.0,0.0,0.0,5.0,0.0,0.0,5.0,5.0,5.0]
//var allPoints = [0.0,0.0,0.1,0.1,0.2,0.2,0.3,0.3,0.4,0.4,0.5,0.5,0.6,0.6,0.7,0.7,0.8,0.8,0.9,0.9,1.0,1.0,1.1,1.1,1.2,1.2,1.3,1.3,1.4,1.4,1.5,1.5,1.6,1.6,1.7,1.7,1.8,1.8,1.9,1.9,2.0,2.0,2.1,2.1,4.0,0.0,8.0,5.0,4.0,10.0,0.0,5.0]



let numberOfPoints = (allPoints.count)/2
let numberOfFixedPoints = 4
let numberOfMovingPoints = numberOfPoints-numberOfFixedPoints


func makeMesh() {
    //Newton's method!!
    for newton in 0...25 {
        
        //find Fij
//        func fij(i: Int,j: Int)->[Double] {
//            let pi = [allPoints[2*i],allPoints[(2*i)+1]]
//            let pj = [allPoints[2*j],allPoints[(2*j)+1]]
//            if (distanceBetweenPoints(pi, p2: pj) < 0.0000001) {
//                return [0.0,0.0]
//            } else {
//                let scalar = (distanceBetweenPoints(pi, p2: pj)-1) / distanceBetweenPoints(pi, p2: pj)
//                return multiplyVectorByScalar([pj[0]-pi[0],pj[1]-pi[1]], scalar: scalar)
//            }
//        }
        
        //Fij with variable spring lenghts
        func fij(i: Int,j: Int)->[Double] {
            let pi = [allPoints[2*i],allPoints[(2*i)+1]]
            let pj = [allPoints[2*j],allPoints[(2*j)+1]]
            if (distanceBetweenPoints(pi, p2: pj) < 0.0000001) {
                return [0.0,0.0]
            } else {
                let scalar = (distanceBetweenPoints(pi, p2: pj)-Double(connections[i][j])) / distanceBetweenPoints(pi, p2: pj)
                return multiplyVectorByScalar([pj[0]-pi[0],pj[1]-pi[1]], scalar: scalar)
            }
        }
        
        func fi(i: Int)->[Double] {
            var result = [0.0,0.0]
            for j in 0..<connections.count {
                if connections[i][j]==1 {
                    result[0] += fij(i,j: j)[0]
                    result[1] += fij(i,j: j)[1]
                }
            }
            return result
        }
        
        func f()->[Double] {
            var list = [Double]()
            for i in 0..<numberOfPoints {
                list.append(fi(i)[0])
                list.append(fi(i)[1])
            }
            
            return list
        }
        
        //find dFij/dPj (2x2 matrix) to make jacobian matrix
//        func dFijdPj(i: Int, j: Int)->[[Double]] {
//            var topLeft = 0.0
//            var bottomRight = 0.0
//            var topRight = 0.0
//            var bottomLeft = 0.0
//            if (i != j) {
//                let dSquared = pow(allPoints[2*j]-allPoints[2*i],2)+pow(allPoints[(2*j)+1]-allPoints[(2*i)+1],2)
//                let dCubed = pow(sqrt(dSquared),3)
//                topLeft = 1.0 - ((dSquared-pow(allPoints[2*j]-allPoints[2*i],2))/dCubed)
//                bottomRight = 1.0 - ((dSquared-pow(allPoints[(2*j)+1]-allPoints[(2*i)+1],2))/dCubed)
//                topRight = ((allPoints[2*j]-allPoints[2*i])*(allPoints[(2*j)+1]-allPoints[(2*i)+1]))/dCubed
//                bottomLeft = topRight
//            }
//            return [[topLeft,topRight],[bottomLeft,bottomRight]]
//        }
        
        //dFijdPj with variable spring lengths!!
        func dFijdPj(i: Int, j: Int)->[[Double]] {
            var topLeft = 0.0
            var bottomRight = 0.0
            var topRight = 0.0
            var bottomLeft = 0.0
            if (i != j) {
                let dSquared = pow(allPoints[2*j]-allPoints[2*i],2)+pow(allPoints[(2*j)+1]-allPoints[(2*i)+1],2)
                let dCubed = pow(sqrt(dSquared),3)
                topLeft = 1.0 - (Double(connections[i][j])*((dSquared-pow(allPoints[2*j]-allPoints[2*i],2))/dCubed))
                bottomRight = 1.0 - (Double(connections[i][j])*((dSquared-pow(allPoints[(2*j)+1]-allPoints[(2*i)+1],2))/dCubed))
                topRight = Double(connections[i][j])*(((allPoints[2*j]-allPoints[2*i])*(allPoints[(2*j)+1]-allPoints[(2*i)+1]))/dCubed)
                bottomLeft = topRight
            }
            return [[topLeft,topRight],[bottomLeft,bottomRight]]
        }
        
        
        //get 2x2 block of jacobian matrix.
        func dFidPj(i: Int, j: Int)->[[Double]] {
            var block = [[0.0,0.0],[0.0,0.0]]
            if i != j {               //0 if no connection, dFij/dPj if connection
                if connections[i][j]==1 {
                    block = dFijdPj(i, j: j)
                } else {
                    block = [[0,0],[0,0]]
                }
            } else {                //if i=j some sum
                for l in 0..<numberOfPoints {
                    if (connections[l][i]==1) {
                        block = sumTwoByTwoMatricies(block, matrix2: dFijdPj(i, j: l))
                    }
                }
            }
            return block
        }
        
        //make jacobian out of 2x2 blocks. size: 2mx2m (2 * numberOfMovingPoints)

        func makeJacobian()->[[Double]] {
            var jacobian = Array(count: (2*numberOfPoints), repeatedValue: Array(count: (2*numberOfPoints), repeatedValue: 0.0))
            for i in 0..<numberOfMovingPoints {
                for j in 0..<numberOfMovingPoints {
                    if i==j {
                        jacobian[2*i][2*j] = -dFidPj(i, j: j)[0][0]
                        jacobian[2*i][(2*j)+1] = -dFidPj(i, j: j)[0][1]
                        jacobian[(2*i)+1][2*j] = -dFidPj(i, j: j)[1][0]
                        jacobian[(2*i)+1][(2*j)+1] = -dFidPj(i, j: j)[1][1]
                    } else {
                        jacobian[2*i][2*j] = dFidPj(i, j: j)[0][0]
                        jacobian[2*i][(2*j)+1] = dFidPj(i, j: j)[0][1]
                        jacobian[(2*i)+1][2*j] = dFidPj(i, j: j)[1][0]
                        jacobian[(2*i)+1][(2*j)+1] = dFidPj(i, j: j)[1][1]
                    }
                }
            }
            for i in (2*numberOfMovingPoints)..<(2*numberOfPoints) {
                jacobian[i][i] = 1.0
            }
            debugPrint(jacobian)
            return jacobian
        }
        
        
        //flatten matrix to turn into array we can invert as a matrix
        func flattenMatrix(matrix: [[Double]])->[Double] {
            var flatMatrix = [Double]()
            for i in 0..<matrix.count {
                for j in 0..<matrix[i].count {
                    flatMatrix.append(matrix[i][j])
                }
            }
            return flatMatrix
        }
        
        let flatJacobian = flattenMatrix(makeJacobian())
        
        //    debugPrint(makeJacobian())
        
        let jacobianInverse = invert( flatJacobian )
        
        //    debugPrint("\njacobian inverse:")
        //    debugPrint(jacobianInverse)
        
        let pk = allPoints
        var fpk = f()
        for i in 0..<fpk.count {
            if i >= (2*numberOfMovingPoints) {
                fpk[i] = 0.0
            }
        }
        
        //    debugPrint("\npk: ")
        //    debugPrint(pk)
        //    debugPrint("\nfpk: ")
        //    debugPrint(fpk)
        
        var multipliedMatrix = multiplyMatrixByVector(jacobianInverse, vector: fpk)
        
        //    debugPrint("\nmultipliedMatrix:")
        //    debugPrint(multipliedMatrix)
        
        var negativeMultipliedMatrix = [Double](count: multipliedMatrix.count, repeatedValue: 0.0)
        for i in 0..<multipliedMatrix.count {
            negativeMultipliedMatrix[i] = multipliedMatrix[i] * -1
        }
        
        //    debugPrint("\nnegativeMultipliedMatrix:")
        //    debugPrint(negativeMultipliedMatrix)
        
        
        var addedMatrix = [Double](count : allPoints.count, repeatedValue : 0.0)
        
        vDSP_vaddD(pk, 1, negativeMultipliedMatrix, 1, &addedMatrix, 1, vDSP_Length(allPoints.count))
        
        allPoints = addedMatrix
        debugPrint("\nallPoints at end:")
        debugPrint(allPoints)
        var total = 0.0
        for sumCount in 0...7 {
            total += pow(fpk[sumCount],2)
        }
        debugPrint("\nclose to zero?:")
        debugPrint(sqrt(total))
        if sqrt(total) < 0.001 {
            break
        }
        
    }
}


*/