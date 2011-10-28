#import "SettingsTouchstoneViewController.h"
#import "MobileKeychainServices.h"
#import "MobileRequestOperation.h"
#import "MITConstants.h"

enum {
    TouchstoneUserCell = 0,
    TouchstonePasswordCell,
    TouchstoneLogoutCell
};

static UIEdgeInsets textCellInsets = {.top = 5,
    .bottom = 5,
    .left = 10,
    .right = 10};

@interface SettingsTouchstoneViewController ()
@property (nonatomic) BOOL authenticationFailed;
@property (nonatomic,retain) MobileRequestOperation *authOperation;
@property (nonatomic,retain) NSArray *tableCells;
@property (nonatomic,assign) UITextField *usernameField;
@property (nonatomic,assign) UITextField *passwordField;
@property (nonatomic,assign) UIButton *logoutButton;
- (void)setupTableCells;
- (IBAction)clearTouchstoneLogin:(id)sender;
- (BOOL)isShibbolethCookie:(NSHTTPCookie*)cookie;

- (void)save:(id)sender;
- (void)cancel:(id)sender;
- (void)saveWithUsername:(NSString*)username password:(NSString*)password;
@end

@implementation SettingsTouchstoneViewController
@synthesize tableCells = _tableCells;
@synthesize authOperation = _authOperation;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize logoutButton = _logoutButton;
@synthesize authenticationFailed = _authenticationFailed;

+ (NSString*)touchstoneUsername
{
    NSDictionary *accountInfo = MobileKeychainFindItem(MobileLoginKeychainIdentifier, NO);
    
    return [accountInfo objectForKey:(id)kSecAttrAccount];
}

- (id)init
{
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.tableCells = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)loadView
{
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:screenRect];
    
    CGRect viewBounds = mainView.bounds;
    {
        [self setupTableCells];
        
        CGRect tableFrame = viewBounds;
        tableFrame.size.height = 128.0;
        UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame
                                                              style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 44.0;
        tableView.allowsSelection = NO;
        tableView.backgroundColor = [UIColor clearColor];
        
        viewBounds.origin.y += tableFrame.size.height;
        [mainView addSubview:tableView];
    }
    
    {
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearButton.enabled = NO;
        [clearButton setTitleColor:[UIColor lightGrayColor]
                          forState:UIControlStateDisabled];
        
        [clearButton setTitle:@"Log out of Touchstone"
                     forState:UIControlStateNormal];
        
        [clearButton addTarget:self
                        action:@selector(clearTouchstoneLogin:)
              forControlEvents:UIControlEventTouchUpInside];
        
        CGRect buttonFrame = CGRectMake(viewBounds.origin.x,
                                        viewBounds.origin.y,
                                        CGRectGetWidth(viewBounds),
                                        44);
        clearButton.frame = UIEdgeInsetsInsetRect(buttonFrame, UIEdgeInsetsMake(0, 20, 0, 20));
        
        NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieStore cookies]) {
            if ([MobileRequestOperation isAuthenticationCookie:cookie]) {
                NSLog(@"Found cookie named: '%@'", [cookie name]);
                clearButton.enabled = YES;
                break;
            }
        }
        
        self.logoutButton = clearButton;
        [mainView addSubview:clearButton];
    }
    
    [self setView:mainView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(save:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private Methods
- (void)setupTableCells
{
    NSMutableArray *cells = [NSMutableArray array];
    
    NSDictionary *credentials = MobileKeychainFindItem(MobileLoginKeychainIdentifier, YES);
    
    {
        UITableViewCell *usernameCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        usernameCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *userField = [[[UITextField alloc] init] autorelease];
        userField.adjustsFontSizeToFitWidth = YES;
        userField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userField.autocorrectionType = UITextAutocorrectionTypeNo;
        userField.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight);
        userField.clearButtonMode = UITextFieldViewModeUnlessEditing;
        userField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        userField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        userField.delegate = self;
        userField.keyboardType = UIKeyboardTypeEmailAddress;
        userField.minimumFontSize = 10.0;
        userField.placeholder = @"Username or Email";
        userField.returnKeyType = UIReturnKeyNext;
        userField.textAlignment = UITextAlignmentLeft;
        
        NSString *username = (NSString*)[credentials objectForKey:(id)kSecAttrAccount];
        if ([username length]) {
            userField.text = username;
        }
        
        userField.frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, 320, 44), textCellInsets);
        self.usernameField = userField;
        [usernameCell.contentView addSubview:userField];
        
        [cells addObject:usernameCell];
    }
    
    {
        UITableViewCell *passwordCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        passwordCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *passField = [[[UITextField alloc] init] autorelease];
        passField.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleWidth);
        passField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        passField.delegate = self;
        passField.placeholder = @"Password";
        passField.returnKeyType = UIReturnKeyDone;
        passField.secureTextEntry = YES;
        
        NSString *password = (NSString*)[credentials objectForKey:(id)kSecValueData];
        if ([password length]) {
            passField.text = password;
        }
        
        passField.frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, 320, 44), textCellInsets);
        
        self.passwordField = passField;
        [passwordCell.contentView addSubview:passField];
        [cells addObject:passwordCell];
    }

    self.tableCells = cells;
}

- (BOOL)isShibbolethCookie:(NSHTTPCookie*)cookie
{
    NSString *name = [cookie name];
    return ([name hasPrefix:@"_saml"] || [name hasPrefix:@"_shib"]);
}

- (void)save:(id)sender
{
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if ([username length] && [password length])
    {
        if (self.authenticationFailed)
        {
            UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"You may not be able to login to Touchstone using the provided credentials. Are you sure you want to continue?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Edit"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Save",nil] autorelease];
            [sheet showInView:self.view];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else if (self.authOperation == nil)
        {
            [self clearTouchstoneLogin:nil];
            self.authOperation = [MobileRequestOperation operationWithModule:@"libraries"
                                                                     command:@"getUserIdentity"
                                                                  parameters:nil];
            
            [self.authOperation authenticateUsingUsername:username
                                                 password:password];
            self.authOperation.completeBlock = ^(MobileRequestOperation *operation, id jsonResult, NSError *error)
            {
                self.authOperation = nil;
                if (error)
                {
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    self.authenticationFailed = YES;
                    
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Touchstone Account"
                                                                    message:@"Unable to verify Touchstone credentials."
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil] autorelease];
                    
                    [alert show];
                }
                else
                {
                    [self saveWithUsername:username
                                  password:password];
                }
            };
            
            [self.authOperation start];
        }
    }
    else
    {
        DLog(@"Saved Touchstone password has been cleared");
        [self saveWithUsername:nil
                      password:nil];
    }
}

- (void)cancel:(id)sender
{
    if (self.authOperation)
    {
        [self.authOperation cancel];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveWithUsername:(NSString*)username password:(NSString*)password
{
    if ([username length] && [password length])
    {
        MobileKeychainSetItem(MobileLoginKeychainIdentifier, username, password);
    }
    else
    {
        [MobileRequestOperation clearAuthenticatedSession];
        MobileKeychainDeleteItem(MobileLoginKeychainIdentifier);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate Methods

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger absoluteIndex = indexPath.section + indexPath.row;
    
    return [self.tableCells objectAtIndex:absoluteIndex];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

#pragma mark - Notification Handlers
- (void)keyboardDidShow:(NSNotification*)notification
{
    
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    
}

- (IBAction)clearTouchstoneLogin:(id)sender
{
    [MobileRequestOperation clearAuthenticatedSession];
    self.logoutButton.enabled = NO;
}

#pragma mark - UITextField Delegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.authenticationFailed = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ([textField isEqual:self.usernameField])
    {
        [self.passwordField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle caseInsensitiveCompare:@"Save"] == NSOrderedSame)
    {
        [self saveWithUsername:self.usernameField.text
                      password:self.passwordField.text];
    }
}

#pragma mark - Touch Handlers
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}
@end
