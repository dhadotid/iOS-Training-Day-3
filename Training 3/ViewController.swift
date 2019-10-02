//
//  ViewController.swift
//  Training 3
//
//  Created by yudha on 02/10/19.
//  Copyright © 2019 yudha. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tfNama: UITextField!
    @IBOutlet weak var tfJabatan: UITextField!
    @IBOutlet weak var tblKaryawan: UITableView!
    @IBOutlet weak var bannerIklan: GADBannerView!
    
    
    var ref: DatabaseReference!
    var karyawan = [KaryawanModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate = ky listener
        tblKaryawan.delegate = self
        tblKaryawan.dataSource = self
        
        ref = Database.database().reference().child("dataKaryawan")
        
        reloadDataKaryawan()
        
        bannerIklan.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerIklan.rootViewController = self
        bannerIklan.load(GADRequest())
    }
    
    func reloadDataKaryawan(){
        ref.observe(DataEventType.value) { (DataSnapshot) in
            if DataSnapshot.childrenCount > 0{
                self.karyawan.removeAll()
                for data in DataSnapshot.children.allObjects as! [DataSnapshot]{
                    let datas = data.value as! [String: String]
                    let id = datas["id"]
                    let nama = datas["nama"]
                    let jabatan = datas["jabatan"]
                    let karyawan = KaryawanModel(id: id!, nama: nama!, jabatan: jabatan!)
                    self.karyawan.append(karyawan)
                    self.tblKaryawan.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return karyawan.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellKaryawan")
        cell?.textLabel?.text = karyawan[indexPath.row].nama
        cell?.detailTextLabel?.text = karyawan[indexPath.row].jabatan
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let karyawan = self.karyawan[indexPath.row]
        
        let alert = UIAlertController(title: "Info", message: "Update Data", preferredStyle: .alert)
        let update = UIAlertAction(title: "Update", style: .default) { (UIAlertAction) in
            let id = karyawan.id
            let nama = alert.textFields?[0].text
            let jabatan = alert.textFields?[1].text
            
            let params = ["id": id, "nama" : nama, "jabatan" : jabatan]
            self.ref.child(id!).setValue(params)
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.ref.child(karyawan.id!).setValue(nil)
            self.karyawan.remove(at: indexPath.row)
            self.tblKaryawan.reloadData()
        }
        
        alert.addTextField { (textNama) in
            textNama.text = karyawan.nama
        }
        alert.addTextField { (textJabatan) in
            textJabatan.text = karyawan.jabatan
        }
        
        alert.addAction(update)
        alert.addAction(delete)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnInsert(_ sender: Any) {
        if tfNama.text == "" || tfJabatan.text == "" {
            print("Data tidak boleh kosong")
        }else{
            let key = ref.childByAutoId().key
            let params = ["id" : key, "nama" : tfNama.text, "jabatan" : tfJabatan.text]
            ref.child(key!).setValue(params)
            
            tfNama.text = ""
            tfJabatan.text = ""
            tfNama.becomeFirstResponder()
        }
    }
    
}

