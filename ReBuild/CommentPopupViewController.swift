import UIKit

class CommentPopupViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    var onSave: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.shadowOpacity = 0.3
        backgroundView.layer.shadowRadius = 6
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let text = commentTextField.text, !text.isEmpty else { return }
        onSave?(text)
        dismiss(animated: true)
    }
}
