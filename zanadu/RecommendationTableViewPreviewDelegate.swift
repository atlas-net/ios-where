//
//  RecommendationTableViewPreviewDelegate.swift
//  Atlas
//
//  Created by liudeng on 16/7/1.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation

@available(iOS 9.0, *)
typealias GetRecommendationAtRowIndexBlock = (IndexPath) -> Recommendation?

@available(iOS 9.0, *)
class RecommendationTableViewPreviewDelegate  : NSObject, UIViewControllerPreviewingDelegate{
    
    var viewController : UIViewController
    var tableView : UITableView
    var recommendationGetBlock : GetRecommendationAtRowIndexBlock
    
    init(viewController : UIViewController, tableview : UITableView, recommendationGetBlock : @escaping GetRecommendationAtRowIndexBlock) {
        self.viewController = viewController
        self.tableView = tableview
        self.recommendationGetBlock = recommendationGetBlock
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let point = self.viewController.view.convert(location, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        guard let _ = indexPath else{
            return nil
        }
        let recommendation = recommendationGetBlock(indexPath!)
        if recommendation == nil{
            return nil
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        return previewViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        viewController.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

@available(iOS 9.0, *)
extension RecommendationTableViewPreviewDelegate: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {
    // Returning None here makes sure that the Popover is actually presented as a Popover and
    // not as a full-screen modal, which is the default on compact device classes.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
