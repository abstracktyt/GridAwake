import SwiftUI
import AVFoundation

// MARK: - QRScannerView

struct QRScannerView: View {
    var onScan: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var permissionGranted = false
    @State private var permissionDenied  = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if permissionGranted {
                CameraPreview(onScan: { value in
                    onScan(value)
                })
                .ignoresSafeArea()

                // Viewfinder overlay
                VStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 260, height: 260)
                        // Corner brackets
                        CornerBrackets()
                            .stroke(Color.blue, lineWidth: 4)
                            .frame(width: 260, height: 260)
                    }
                    Spacer()
                    Text("Наведіть на QR код GridAwake")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                }
            } else if permissionDenied {
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Доступ до камери заблоковано.\nДозвольте в Налаштуваннях.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Button("Відкрити Налаштування") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    .foregroundColor(.blue)
                }
            } else {
                ProgressView().tint(.white)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(16)
                    }
                }
                Spacer()
            }
        }
        .onAppear { checkPermission() }
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    permissionGranted = granted
                    permissionDenied  = !granted
                }
            }
        default:
            permissionDenied = true
        }
    }
}

// MARK: - Camera Preview (UIKit bridge)

struct CameraPreview: UIViewRepresentable {
    let onScan: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        context.coordinator.setup(in: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onScan: (String) -> Void
        private var session: AVCaptureSession?
        private var layer: AVCaptureVideoPreviewLayer?
        private var scanned = false

        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }

        func setup(in view: UIView) {
            let s = AVCaptureSession()
            session = s

            guard let device = AVCaptureDevice.default(for: .video),
                  let input  = try? AVCaptureDeviceInput(device: device),
                  s.canAddInput(input) else { return }
            s.addInput(input)

            let output = AVCaptureMetadataOutput()
            guard s.canAddOutput(output) else { return }
            s.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]

            let previewLayer = AVCaptureVideoPreviewLayer(session: s)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
            layer = previewLayer

            DispatchQueue.global(qos: .userInitiated).async { s.startRunning() }

            // Update frame on layout
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                previewLayer.frame = view.bounds
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput objects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard !scanned,
                  let obj = objects.first as? AVMetadataMachineReadableCodeObject,
                  let value = obj.stringValue else { return }
            scanned = true
            session?.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onScan(value)
        }
    }
}

// MARK: - Corner Brackets shape

struct CornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let len: CGFloat = 30
        let r  = rect

        func corner(_ x: CGFloat, _ y: CGFloat, _ dx: CGFloat, _ dy: CGFloat) {
            p.move(to: CGPoint(x: x + dx * len, y: y))
            p.addLine(to: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x, y: y + dy * len))
        }

        corner(r.minX, r.minY,  1,  1)
        corner(r.maxX, r.minY, -1,  1)
        corner(r.minX, r.maxY,  1, -1)
        corner(r.maxX, r.maxY, -1, -1)
        return p
    }
}
