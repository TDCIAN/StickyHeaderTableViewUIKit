//
//  ViewController.swift
//  StickyHeaderTableViewUIKit
//
//  Created by 김정민 on 12/30/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private lazy var stickyHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["First", "Second", "Third"])
        segmentedControl.backgroundColor = .green
        segmentedControl.selectedSegmentIndex = 1
        return segmentedControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBlue
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.className)
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        return tableView
    }()
    
    private var headerStopOffset: CGFloat {
        return self.stickyHeaderView.frame.height - self.segmentedControl.frame.height
    }
    
    var numberOfCells = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.dataSource = self
        
        self.tableView.contentInset = UIEdgeInsets(
            top: self.stickyHeaderView.frame.height,
            left: 0,
            bottom: 0,
            right: 0
        )
    }
    private func setup() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.stickyHeaderView)
        self.view.addSubview(self.segmentedControl)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaInsets)
        }
        
        self.stickyHeaderView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaInsets.top)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(200)
        }
        
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.stickyHeaderView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.className, for: indexPath) as? TableViewCell
        else { return UITableViewCell() }
        
        cell.config(title: "This is cell number: \(indexPath.row + 1)")
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let totalOffset = scrollView.contentOffset.y + self.stickyHeaderView.frame.height + self.segmentedControl.frame.height
        
        // (1) HeaderView
        var headerTransform = CATransform3DIdentity
        
        if totalOffset > 0 {

            headerTransform = CATransform3DTranslate(
                headerTransform,
                0,
                max(-self.headerStopOffset, -totalOffset),
                0
            )
            
        }
        
        self.stickyHeaderView.layer.transform = headerTransform

        // (2) SegmentView
        var segmentTransform = CATransform3DIdentity
        
        segmentTransform = CATransform3DTranslate(
            segmentTransform,
            0,
            max(-self.headerStopOffset, -totalOffset) - 10,
            0
        )

        self.segmentedControl.layer.transform = segmentTransform
    }
}

final class TableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(title: String) {
        self.titleLabel.text = title
    }
}

extension UIView {
    static var className: String {
        return String(describing: self)
    }
}
