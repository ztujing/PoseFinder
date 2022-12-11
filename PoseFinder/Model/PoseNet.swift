/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation details of a facade to interact with the PoseNet model, includes input
 preprocessing and calling the model's prediction function.
*/

import CoreML
import Vision

protocol PoseNetDelegate: AnyObject {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput)
}

class PoseNet {
    /// The delegate to receive the PoseNet model's outputs.
    weak var delegate: PoseNetDelegate?
    var type = ""
    /// The PoseNet model's input size.
    ///
    /// All PoseNet models available from the Model Gallery support the input sizes 257x257, 353x353, and 513x513.
    /// Larger images typically offer higher accuracy but are more computationally expensive. The ideal size depends
    /// on the context of use and target devices, typically discovered through trial and error.
    let modelInputSize = CGSize(width: 513, height: 513)

    /// The PoseNet model's output stride.
    ///
    /// Valid strides are 16 and 8 and define the resolution of the grid output by the model. Smaller strides
    /// result in higher-resolution grids with an expected increase in accuracy but require more computation. Larger
    /// strides provide a more coarse grid and typically less accurate but are computationally cheaper in comparison.
    ///
    /// - Note: The output stride is dependent on the chosen model and specified in the metadata. Other variants of the
    /// PoseNet models are available from the Model Gallery.
    let outputStride = 16

    /// The Core ML model that the PoseNet model uses to generate estimates for the poses.
    ///
    /// - Note: Other variants of the PoseNet model are available from the Model Gallery.
    private let poseNetMLModel: MLModel

    init(type:String) throws {
        self.type = type
        poseNetMLModel = try PoseNetMobileNet075S16FP16(configuration: .init()).model
    }

    /// Calls the `prediction` method of the PoseNet model and returns the outputs to the assigned
    /// `delegate`.
    ///
    /// - parameters:
    ///     - image: Image passed by the PoseNet model.
    func predict(_ image: CGImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            //Prepare the Input for the PoseNet Model [PoseNetモデルの入力を準備します]
            // After receiving the captured image, the app wraps it in an instance of PoseNetInput, a custom feature provider, to resize the image to the specified size. [キャプチャされた画像を受信した後、アプリはそれをカスタム機能プロバイダーであるPoseNetInputのインスタンスにラップして、指定されたサイズに画像のサイズを変更します。]
            
            // Wrap the image in an instance of PoseNetInput to have it resized
            // before being passed to the PoseNet model.
            let input = PoseNetInput(image: image, size: self.modelInputSize)

            
            //Pass the Input to the PoseNet Model [入力をPoseNetモデルに渡します]
            // The sample app then proceeds to pass the input to the PoseNet’s prediction(from:) function to obtain its outputs, which the app uses to detect poses. [次に、サンプルアプリは、入力をPoseNetのprediction（from :)関数に渡して、その出力を取得します。この出力は、アプリがポーズの検出に使用します。]
            
            guard let prediction = try? self.poseNetMLModel.prediction(from: input) else {
                return
            }
            //Next, the sample app wraps the PoseNet model outputs in an instance of PoseNetOutput, along with the model’s input size and output stride, before passing it back to the assigned delegate for analysis. [次に、サンプルアプリは、分析のために割り当てられたデリゲートに返す前に、モデルの入力サイズと出力ストライドとともに、PoseNetOutputのインスタンスでPoseNetモデルの出力をラップします。]
//            print(prediction)
            let poseNetOutput = PoseNetOutput(prediction: prediction,
                                              modelInputSize: self.modelInputSize,
                                              modelOutputStride: self.outputStride)

            DispatchQueue.main.async {
                self.delegate?.poseNet(self, didPredict: poseNetOutput)
            }
        }
    }
}
