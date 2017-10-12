//
//  ApplicantEval.swift
//  ReviewerAPI
//
//  Created by Christine Oakes on 10/2/17.
//  Copyright © 2017 Maedchen Oakes Prod. All rights reserved.
//

import Foundation
import Alamofire

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

enum Evaluation: String {
    case id = "id"
    case ReviewerID = "reviewerId"
    case ApplicantId = "applicantId"
    case AssignedDate = "assignedDt"
    case ReviewerRecommendCode = "reviewerRecommendationCode"
    case ReviewerRecommendName = "reviewerRecommendationName"
    case RecommendationDate = "recommendationDt"
    case Confirm = "confirm"
    case ConfirmDate = "confirmedDt"
    case ReviewDocsChangeDt = "reviewDocsChangedDt"
    case ProposedAmount = "proposedScholarshipAmount"
    case RetakeLSAT = "recommendRetakeLsat"
    case NeedInfo = "needMoreInformation"
    case ReviewerUdf1 = "reviewerUdf1"
    case ReviewerUdf2 = "reviewerUdf2"
    case ReviewerUdf3 = "reviewerUdf3"
    case ReviewerUdf4 = "reviewerUdf4"
    case ReviewerUdf5 = "reviewerUdf5"
    case ReviewerUdf6 = "reviewerUdf6"
    case ReviewerUdf7 = "reviewerUdf7"
    case Note = "note"
    case CreatedBy = "createdBy"
    case CreatedDt = "createdDt"
    case EditedBy = "editedBy"
    case EditedDt = "editedDt"
    case ApplicantFullName = "applicantFullName"
    case ReviewerFullName = "reviewerFullName"
    case ApplicantConcatScore = "applicantConcatScore"
    case ApplicantHighLSATScore = "applicanthighLSATScore"
    case Url = "url"
}

class EvalWrapper {
    var evals: [Eval]?
    var count: Int?
    var next: String?
    var previous: String?
}

class Eval {
    var id: Int?
    var reviewerID: Int?
    var applicantID: Int?
    var assignedDt: String?
    var reviewerRecommendationName: String?
    var applicantConcatScore: String?
    var confirm: DarwinBoolean?
    var reviewDocsChanged: Date?
    var proposedScholarshipAmount: String?
    var reviewerUDF1: String?
    var note: String?
    var applicantFullName: String?
    var applicantHighLSATScore: String?
    var url: String?
    
    required init(json: [String: Any]) {
        self.id = json[Evaluation.id.rawValue] as? Int
        self.applicantFullName = json[Evaluation.ApplicantFullName.rawValue] as? String
        self.applicantHighLSATScore = json[Evaluation.ApplicantHighLSATScore.rawValue] as? String
        self.applicantConcatScore = json[Evaluation.ApplicantConcatScore.rawValue] as? String
        self.reviewerRecommendationName = json[Evaluation.ReviewerRecommendName.rawValue] as? String
        self.assignedDt = json[Evaluation.AssignedDate.rawValue] as? String
        // TODO: more fields!
    }
    
    // MARK: Endpoints
 
    class func endpointForEval() -> String {
        return "http://lsacpilot.eastus.cloudapp.azure.com:84/api/Evaluation/2/"
        //return "http://mob-lhub1.lsac.org:3000/Evaluations"
}
    class func endpointForId(_ id: Int) -> String {
        var url: String
        url = "http://lsacpilot.eastus.cloudapp.azure.com:84/api/ApplicantEvaluation/2/\(id)"
        return url
    }
    
    // GET / Read single eval
    class func EvalByID(_ id: Int, completionHandler: @escaping (Result<Eval>) -> Void) {
        let _ = Alamofire.request(Eval.endpointForId(id))
            .responseJSON { response in
                if let error = response.result.error {
                    completionHandler(.failure(error))
                    return
                }
                let evalResult = Eval.evalFromResponse(response)
                completionHandler(evalResult)
        }
    }
    
    // GET / Read all
    fileprivate class func getEvalAtPath(_ path: String, completionHandler: @escaping (Result<EvalWrapper>) -> Void) {
        // make sure it's HTTPS because sometimes the API gives us HTTP URLs
        guard var urlComponents = URLComponents(string: path) else {
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            completionHandler(.failure(error))
            return
        }
        urlComponents.scheme = "http"
        guard let url = try? urlComponents.asURL() else {
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            completionHandler(.failure(error))
            return
        }
        let _ = Alamofire.request(url)
            .responseJSON { response in
                if let error = response.result.error {
                    completionHandler(.failure(error))
                    return
                }
                let evalWrapperResult = Eval.evalArrayFromResponse(response)
                completionHandler(evalWrapperResult)
        }
    }
    class func getEvals(_ completionHandler: @escaping (Result<EvalWrapper>) -> Void) {
        getEvalAtPath(Eval.endpointForEval(), completionHandler: completionHandler)
    }
    
    class func getMoreEvals(_ wrapper: EvalWrapper?, completionHandler: @escaping (Result<EvalWrapper>) -> Void) {
        guard let nextURL = wrapper?.next else {
            let error = BackendError.objectSerialization(reason: "Did not get wrapper for more evals")
            completionHandler(.failure(error))
            return
        }
        getEvalAtPath(nextURL, completionHandler: completionHandler)
    }
    private class func evalFromResponse(_ response: DataResponse<Any>) -> Result<Eval> {
        guard response.result.error == nil else {
            // got an error in getting the data, need to handle it
            print(response.result.error!)
            return .failure(response.result.error!)
        }
        
        // make sure we got JSON and it's a dictionary
        guard let json = response.result.value as? [String: Any] else {
            print("didn't get eval object as JSON from API")
            return .failure(BackendError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        
        let evals = Eval(json: json)
        return .success(evals)
    }
    private class func evalArrayFromResponse(_ response: DataResponse<Any>) -> Result<EvalWrapper> {
        guard response.result.error == nil else {
            // got an error in getting the data, need to handle it
            print(response.result.error!)
            return .failure(response.result.error!)
        }
        
        // make sure we got JSON and it's a dictionary
        guard let json = response.result.value as? [String: Any] else {
            print("didn't get species object as JSON from API")
            return .failure(BackendError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        
        let wrapper:EvalWrapper = EvalWrapper()
        wrapper.next = json["next"] as? String
        wrapper.previous = json["previous"] as? String
        wrapper.count = json["count"] as? Int
        
        var allEvals: [Eval] = []
        if let results = json["result"] as? [[String: Any]] {
            for jsonEvals in results {
                let evals = Eval(json: jsonEvals)
                allEvals.append(evals)
            }
        }
        wrapper.evals = allEvals
        return .success(wrapper)
    }

}


