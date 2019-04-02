//
//  CategoryListsView.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/5/18.
//  Copyright © 2016年 Atlas. All rights reserved.
//


@objc protocol CategoryListsViewDelegate : NSObjectProtocol{
    @objc optional  func didSelectCategoryListsRowCallBack(_ categorys : [Category])

}

class CategoryListsView: UIView,UITableViewDelegate,UITableViewDataSource{
    enum viewType{
        case noTitleView,hasTitleView
    }

    var  categoryArray = [Category]()
    var  subCategoryArray = [SubCategory]()

    var statusDic : [String : Bool] = ["1":false]
    fileprivate var cellIdentifer = "CategoryCatalogCell"
    var  sections = 1
    var  table = UITableView()
    var  currType: viewType = .noTitleView
    var  delegate : CategoryListsViewDelegate?
    var  selectedCategoryArray = [Category]()
    var category : Category?
    var  cellHeight:CGFloat = 40

    internal   func  initWithType() {
        if currType == .noTitleView {
            table.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }else{
            let titleView = UILabel()
            titleView.backgroundColor = UIColor(bd_hexColor : "5a5f60")
            titleView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 40)
            titleView.text = "选择类型"
            titleView.textAlignment = .center
            titleView.textColor = UIColor.white
            self.addSubview(titleView)
            table.frame = CGRect(x: 0, y: 33, width: frame.size.width, height: frame.size.height - 33)
        }
        self.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        table.register(UINib(nibName: "CategoryCatalogCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifer)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        
        
        for category in categoryArray{
            let subCate = SubCategory(name: category.name ,status: category.status!)
            subCategoryArray.append(subCate)
        }
        
    }
    
    func onCancelButtonTapped(_ sender : UIButton) {
        self.removeFromSuperview()
        selectedCategoryArray.removeAll()
    }
    
    func onConfirmButtonTapped(_ sender : UIButton) {
        self.removeFromSuperview()
        selectedCategoryArray.removeAll()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var  count = 7
        if categoryArray.count > 0 {
            count = categoryArray.count
        }
        return count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currType != .noTitleView {
            cellHeight = 50
        }
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath) as! CategoryCatalogCell
        
                
        if currType == .noTitleView {
            cell.selectIconImgView.isHidden = true
            cell.titleLabel.highlightedTextColor = Config.Colors.CateCellHightliedTextColor
        }else{
            cell.selectIconImgView.isHidden = false
            cell.selectionStyle = .none
        }
        cell.configCellWithIndexPath(subCategoryArray, indexPath: indexPath)
        
        let index = (indexPath as NSIndexPath).row
        let category = subCategoryArray[index]
        let count = RecommendationFactory.sharedInstance.categorys?.count
        if  count != nil && count! > 0 {
            for cate in RecommendationFactory.sharedInstance.categorys!{
                if cate.name == category.name{
                    let  isContain = self.selectedCategoryArray.contains(cate)
                    if !isContain{
                        self.selectedCategoryArray.append(cate)
                    }
                    break
                }
                
            }
        }
        

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currType == .noTitleView {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        let subCate = subCategoryArray[(indexPath as NSIndexPath).row]
        subCate.isSelected = !subCate.isSelected!
        let   cate = categoryArray[(indexPath as NSIndexPath).row]
        
        if subCate.isSelected! {
            if self.selectedCategoryArray.count < 2 {
                self.selectedCategoryArray.append(cate)

            }else{
                subCate.isSelected = !subCate.isSelected!
                showTipsToast()
            }
        }else{
            for (index, value) in selectedCategoryArray.enumerated(){
                if value == cate {
                    self.selectedCategoryArray.remove(at: index)
                }
            }
        }
        self.table.reloadData()


        if self.selectedCategoryArray.count <= 2 {
        }else{
            return
        }
        
        if let delegate = self.delegate {
            delegate.didSelectCategoryListsRowCallBack!(self.selectedCategoryArray)
        }
    }

    func showTipsToast()  {
        let tips = NSLocalizedString("Please select one to two categories", comment:"请选择一到两个类别")
        JLToast.makeText(tips, duration: JLToastDelay.ShortDelay).show()
    }
    
}
