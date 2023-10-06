//
//  WeatherListViewCell.swift
//  YumemiWorks
//
//  Created by user on 2023/09/07.
//

import UIKit

class WeatherListViewCell: UITableViewCell {

    @IBOutlet weak var areaName: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
