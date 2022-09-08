//
//  MainTabbarController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/23.
//

import UIKit

class MainTabbarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    // MARK: - Helpers
    
    private func configureViewControllers() {
        view.backgroundColor = .clear
        
        let newBooksViewController = NewBooksViewController()
        newBooksViewController.viewModel = NewBooksViewModel()
        let newBook = configureNavigationController(title: "New", tabbarImage: UIImage(systemName: "book") ?? UIImage(), rootViewController: newBooksViewController)
        
        let searchViewController = SearchViewController()
        searchViewController.viewModel = SearchViewModel()
        let searchBook = configureNavigationController(title: "Search", tabbarImage: UIImage(systemName: "magnifyingglass") ?? UIImage(), rootViewController: searchViewController)
        
        viewControllers = [newBook, searchBook]
        tabBar.tintColor = .systemBlue
    }
    
    private func configureNavigationController(title: String, tabbarImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = tabbarImage
        nav.navigationBar.tintColor = .systemBlue
        return nav
    }
}
