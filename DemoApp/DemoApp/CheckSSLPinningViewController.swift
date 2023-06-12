//
//  CheckSSLPinningViewController.swift
//  DemoApp
//
//  Created by SENTHIL KUMAR on 09/06/23.
//

import UIKit
import Alamofire

struct ResponseData: Codable {
    var status: String?
}

class CheckSSLPinningViewController: UIViewController {
    
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var collectionNameStaticLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistNameStaticLabel: UILabel!
    
    var session: URLSession?
    var afSession: Session?
    var ACCESSTOKEN = "U2FsdGVkX1/QlrBZwDjAGvD8Xp5VzCK2r5bUpW7/3D/ZH0/GtmYaKYjs3GlD+O6kUZKwxD2lBoJ38q+2VeHpZxozlXfzPZjSsBIkXc2KXpvnFi97IrHG670IzKC7I8OpakbUz3ywJ1FiYzX5IyuzukefIK+KK5bmLHN00ig/kJi1dm5WaK45PPaIUSvIYnCMKrmS+nrDxyZyuit+REGIEZR14GsiwN7klIz83AvvLuE62/bMWyrKHD+DZ3WrYhbISFT3wXMyMGqKapns23Tj5Cv+nPoXQus+XmC4Tp7x9HUdJcltu4ji9COwrg+9I2WRzVKPYfejLN7dtXNYo88IrbV69kf8Hot72hSJfncipoY="
    var REFRESHTOKEN = "U2FsdGVkX1881LXBxJeN9CmaMycOU0aeyYDp4HP3zhMf6OoYhpF9UHLVdLV9vnXZ8pn/yh38QAmPNof0gcow2JheF2dSP5CXavLDHPmW5fKjXDdlyj/WEoT4K904O2+RZOcGOfIza6whQPtkq4pWJ4BkNJOjRxF6WMXaB3ihrC/dycOjJtIwWxt+QsR7I7k2RR8KjTa3ziEqnzZRtXPgJiruFwJW7WUMEv/K5s7ACIERL9i57SkMDdztGee6QTEkqvAgQ8qjIw7HhlegF3IdUwDtlVGJbNtkKVty8zAL/gSS8mkL7DzJadLzD6vqPwHuPTAk4hdaFp2KOkZ2yu3DxtTvI7FVxpTfxXq4+MDDBzg="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = URLSession.init(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        afSessionManger()
        callURLSessionApi()
        callAFSessionApi()
    }
    
    func afSessionManger() {
        let manager = ServerTrustManager(evaluators: evaluators)
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.waitsForConnectivity = true
        /* With SSL Pinning */
        afSession = Session(configuration: configuration, serverTrustManager: manager)
        /* Without SSL Pinning */
        //        afSession = Session()
    }
    
}

//MARK: Using URLSession and URLSessionDelegate
extension CheckSSLPinningViewController: URLSessionDelegate {
    
    func callURLSessionApi() {
        let params: [String: Any] = ["mobile": "8925801713"]
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        
        guard let url = URL(string: "https://uat-fleetdrive.m2pfintech.com/lq-middleware/lqfleet/customer/detailsByMobile") else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("lqfleet", forHTTPHeaderField: "tenant")
        request.addValue("Bearer \(ACCESSTOKEN)", forHTTPHeaderField: "accesstoken")
        request.addValue("Bearer \(REFRESHTOKEN)", forHTTPHeaderField: "refreshtoken")
        
        let task = session?.dataTask(with: request) {(data, resonse, error)in
            guard error == nil else {return}
            guard let dat = data else {return}
            do {
                let content = try JSONDecoder().decode(AccountDetailsRespone.self, from: dat)
                DispatchQueue.main.async {
                    self.artistNameLabel.text = "\(content.result?.name ?? "")"
                }
                
            } catch {
                print("Error",error)
            }
        }
        task?.resume()
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust, let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return
        }
        //SSL Policy for domain check
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        
        //Evaluate the certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        //Local and Remote Certificate Data
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
        
        if let filePath = Bundle.main.path(forResource: "UAT_M2Pfintech", ofType: "cer"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            
            if (isServerTrusted && remoteCertificateData.isEqual(to: data as Data)) {
                let credential: URLCredential = URLCredential(trust: serverTrust)
                print("Certification pinning is successfull")
                completionHandler(.useCredential, credential)
            } else {
                //failure happened
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
}

//MARK: Using Alamofire Session and Alamofire SessionDelegate
extension CheckSSLPinningViewController { //SessionDelegate

    func certificate() -> SecCertificate? {
        guard let filePath = Bundle.main.path(forResource: "UAT_M2Pfintech", ofType: "cer"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
            return nil
        }
        return certificate
    }
    
    // MARK: - Host To Evaluate
    var hostToEvaluate: String {
        let urlString = "https://uat-fleetdrive.m2pfintech.com/"
        guard let hostURL = URL(string: urlString), let host = hostURL.host else {
            return ""
        }
        return host
    }
    
    // MARK: - Evaluators
    var evaluators: [String: ServerTrustEvaluating] {
        guard let sslCertificate = certificate() else {
            return [hostToEvaluate: DisabledTrustEvaluator()]
        }
        return [hostToEvaluate: PinnedCertificatesTrustEvaluator(certificates: [sslCertificate])]
    }
    
    func callAFSessionApi() {
        guard let url = URL(string: "https://uat-fleetdrive.m2pfintech.com/lq-middleware/lqfleet/customer/detailsByMobile") else {return}
        let params: Parameters = ["mobile": "8925801713"]
        let headers: HTTPHeaders? = ["Content-Type": "application/json",
                                     "accesstoken": "Bearer \(ACCESSTOKEN)",
                                     "refreshtoken": "Bearer \(REFRESHTOKEN)",
                                     "tenant": "lqfleet"]
        
        self.afSession?.request(url,
                                method: .post,
                                parameters: params,
                                headers: headers).validate().response { (response) in
            
            _ = response.response?.statusCode
            switch response.result {
            case .success(let json):
                print("Response Json:- \(json ?? Data())")
                print(response.response?.allHeaderFields as Any)
            case .failure(let error):
                print(error)
                let isServerTrustEvaluationError =
                error.asAFError?.isServerTrustEvaluationError ?? false
                let errorMessage: String
                if isServerTrustEvaluationError {
                    errorMessage = "Certificate Pinning Error"
                } else {
                    errorMessage = error.localizedDescription
                }
                if errorMessage == "Unauthenticated." {
                    return
                }
            }
        }
    }
    
}
