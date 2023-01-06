//
//  HomeVc.swift
//  FourSquareApp
//
//  Created by Harsha R Mundaragi on 02/01/23.
//

import UIKit


class HomeVc: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource ,sendingIndex {
    
    var objectOfHomeViewModel = HomeViewModel.objectOfViewModel
    
    var objectOfUserDefaults = UserDefaults()
    var objectOfKeyChain = KeyChain()
    
    @IBOutlet weak var name_Loginbutton: UIButton!
    @IBOutlet weak var burgerWidth: NSLayoutConstraint!
    @IBOutlet weak var topTapView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    
    @IBOutlet weak var containerBackView: UIView!
    @IBOutlet weak var containerView: UIView!
    var menuOut = false
    
    var pageView: HomePageController?
    
    var collectionItem = ["Near you","Toppic","Popular","Lunch","Coffee"]
    override func viewDidLoad() {
        super.viewDidLoad()
        let tokenIs = getToken()
        print("user token is : \(tokenIs)")
    
        if tokenIs != ""{
            
            name_Loginbutton.isEnabled = false
        }else{
            name_Loginbutton.isEnabled = true
        }
        
        topTapView.isHidden = true
        burgerWidth.constant = 0
        if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        self.collectionView.performBatchUpdates(nil) { _ in
            self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        }
        
    }
    
    func gotoIndex(index: Int) {
        collectionView.scrollToItem(at: [0,index], at: .centeredHorizontally, animated: true)
        collectionView.selectItem(at: [0,index], animated: true, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
    }

    
    @IBAction func burgerButtonTapped(_ sender: Any) {
        
        if menuOut == false{
            topTapView.isHidden = false
            burgerWidth.constant = 300
            leading.constant = 300
            trailing.constant = -300
            top.constant = 50
            bottom.constant = 50
            menuOut = true
        }
        else{
            burgerWidth.constant = 0
            leading.constant = 0
            trailing.constant = 0
            top.constant = 0
            bottom.constant = 0
            menuOut = false
            
        }
        
        UIView.animate(withDuration: 0.3 , animations: {
            self.view.layoutIfNeeded()
        }) { (status) in
            
        }
        
        
        
    }
    
    @IBAction func burgerLogOutButtonTapped(_ sender: UIButton) {
        
        let call = getToken()
        
        if call != ""{
            
            let refreshAlert = UIAlertController(title: "ALERT", message: "Are you sure you want to LOG OUT ...!!!", preferredStyle: UIAlertController.Style.alert)

                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

                        let loader =   self.loader()
                        self.objectOfHomeViewModel.signOutApiCall(tokenToSend: call){ status in
                            print("9900",status)
                            DispatchQueue.main.async() {
                                self.stopLoader(loader: loader)
                            if status == true{
                                DispatchQueue.main.async {
                                    var id = ""
                                    if let idIs =  self.objectOfUserDefaults.value(forKey: "userId") as? String{
                                        id = idIs
                                        print("user id is : \(idIs)")
                                    }
                                    print("user id is1 : \(id)")
                                    self.objectOfKeyChain.deletePassword(userId: id)
                                    self.objectOfUserDefaults.set("", forKey: "userId")
                                    self.objectOfUserDefaults.setValue(1, forKey: "SignOut")
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    self.alertMessage(message: "Something went wrong while sign out try again")

                                }
                            }
                            }
                        }
                        print("Handle Ok logic here")

                    }))
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                          print("Handle Cancel Logic here")
                    }))
                    present(refreshAlert, animated: true, completion: nil)
        }else{
            
            
            
        }
  
        
    }
    
    
    @IBAction func burherAboutButtonTapped(_ sender: UIButton) {
        
        let aboutVc = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVc") as? AboutUsVc
        if let vc = aboutVc{
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    @IBAction func burgerFeedbackButtonTapped(_ sender: UIButton) {
        
        let feedbackVc = self.storyboard?.instantiateViewController(withIdentifier: "FeedbackVc") as? FeedbackVc
        if let vc = feedbackVc{
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func burherFavouritesButtonTapped(_ sender: UIButton) {
        
        let favouritVc = self.storyboard?.instantiateViewController(withIdentifier: "FavouiretVc") as? FavouiretVc
        if let vc = favouritVc{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func name_LoginButtontapped(_ sender: UIButton) {
    
        let refreshAlert = UIAlertController(title: "ALERT", message: "Are you not loged in. Pleace login", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

                    self.navigationController?.popToRootViewController(animated: true)
                    print("Handle Ok logic here")

                }))
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                      print("Handle Cancel Logic here")
                }))
                present(refreshAlert, animated: true, completion: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? HomePageController{
        
            self.pageView = vc
            vc.delegate1 = self
        }
    }
    

    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        let searVc = self.storyboard?.instantiateViewController(withIdentifier: "SearchVc") as? SearchVc
        if let vc = searVc{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func tapGestureTapped(_ sender: Any) {
        burgerWidth.constant = 0
        leading.constant = 0
        trailing.constant = 0
        top.constant = 0
        bottom.constant = 0
        menuOut = false
        topTapView.isHidden = true

        UIView.animate(withDuration: 0.3 , animations: {
            self.view.layoutIfNeeded()
        }) { (status) in
            
        }
        
    }
    
    
}

extension HomeVc{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        cell.labelToUpdate.text = collectionItem[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! HomeCollectionViewCell
        cell.labelToUpdate.textColor = .white
        pageView?.goToPAge(indexIs: indexPath.row)

    }

    
}

extension HomeVc: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 5, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
}

extension HomeVc{
    
    func getToken() -> String {
        var id = ""
       let userIdIs = objectOfUserDefaults.value(forKey: "userId")
        if let idIs = userIdIs as? String{
            id = idIs
        }
        print("Home id : \(id)")
        guard let receivedTokenData = objectOfKeyChain.loadData(userId: id) else {print("utr 2")
            return ""}
        guard let receivedToken = String(data: receivedTokenData, encoding: .utf8) else {print("utr 3")
            return ""}
        print("Home token",receivedToken)
        return receivedToken
    }
}
