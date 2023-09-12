//
//  SbpCell.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 27.07.2023.
//

import UIKit

class SbpCell: UITableViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .clear
        selectionStyle = .none
        separatorInset = .init(top: 0, left: 36, bottom: 0, right: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCell(model: SbpQRDataModel) {
        nameLabel.text = model.bankName
        guard let string = model.logoURL else { return }
        loadImage(url: string) { image in
            DispatchQueue.main.async {
                self.logoImageView.image = image
            }
        }
    }
    
    private func loadImage(url string: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: string) else { return completion(nil)}
        
        let task = URLSession.shared.dataTask(with: .init(url: url)) { [weak self] data, _, _ in
            guard let _ = self else { return }
            guard let data = data, let image = UIImage(data: data) else { return completion(nil)}
            completion(image)
        }
        
        task.resume()
    }
}
