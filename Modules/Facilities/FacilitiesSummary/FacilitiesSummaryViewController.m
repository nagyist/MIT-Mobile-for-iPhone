#import <QuartzCore/QuartzCore.h>
#import <sys/ucred.h>

#import "FacilitiesSummaryViewController.h"
#import "FacilitiesCategory.h"
#import "FacilitiesLocation.h"
#import "FacilitiesRoom.h"
#import "FacilitiesConstants.h"
#import "FacilitiesRootViewController.h"

@interface FacilitiesSummaryViewController ()
- (UIView*)firstResponderInView:(UIView*)view;
@end

@implementation FacilitiesSummaryViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize pictureButton = _pictureButton;
@synthesize problemLabel = _problemLabel;
@synthesize descriptionView = _descriptionView;
@synthesize emailField = _emailField;
@synthesize characterCount = _characterCount;
@synthesize reportData = _reportData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.imageView = nil;
    self.pictureButton = nil;
    self.problemLabel = nil;
    self.descriptionView = nil;
    self.emailField = nil;
    self.characterCount = nil;
    self.reportData = nil;
    self.scrollView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.autoresizesSubviews = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
    self.imageView.image = [UIImage imageNamed:@"tours/button_photoopp"];
    
    self.descriptionView.layer.cornerRadius = 5.0f;
    self.descriptionView.layer.borderWidth = 2.0f;
    self.descriptionView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descriptionView.delegate = self;
    
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(submitReport:)] autorelease];
    item.title = @"Submit";
    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewWillAppear:(BOOL)animated {
    FacilitiesLocation *location = [self.reportData objectForKey:FacilitiesRequestLocationBuildingKey];
    FacilitiesRoom *room = [self.reportData objectForKey:FacilitiesRequestLocationRoomKey];
    NSString *customLocation = [self.reportData objectForKey:FacilitiesRequestLocationCustomKey];
    NSString *type = [[self.reportData objectForKey:FacilitiesRequestRepairTypeKey] lowercaseString];

    NSString *text = nil;
    
    if (location && room) {
        text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ at %@ near room %@.",type,location.name,[room displayString]];
    } else if (location) {
        if ([customLocation hasSuffix:@"side"]) {
            text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ %@ %@.",type,[customLocation lowercaseString],location.name];
        } else {
            text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ at %@ near %@.",type,location.name,[customLocation lowercaseString]];
        }
    } else {
        text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ in %@",type,customLocation];
    }
    
    self.problemLabel.text = text;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.imageView = nil;
    self.pictureButton = nil;
    self.problemLabel = nil;
    self.descriptionView = nil;
    self.emailField = nil;
    self.characterCount = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectPicture:(id)sender { 
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Take Photo",@"Choose Existing", nil] autorelease];
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self.view];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[[UIImagePickerController alloc] init] autorelease];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        [self presentModalViewController:controller
                                animated:YES];
    }
}

- (IBAction)submitReport:(id)sender {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[FacilitiesRootViewController class]]) {
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
}


#pragma mark -
#pragma mark UITextViewDelegate
static NSUInteger kMaxCharacters = 150;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else if ((range.length == 1) && ([text length] == 0)) {
        return YES;
    } else if ((range.location + [text length]) >= kMaxCharacters) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *controller = [[[UIImagePickerController alloc] init] autorelease];
    if (buttonIndex == 0) {
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.showsCameraControls = YES;
    } else if (buttonIndex == 1) {
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (buttonIndex == 2) {
        return;
    }
    
    controller.delegate = self;
    [self presentModalViewController:controller
                            animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (image) {
        self.imageView.image = image;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Notification Methods
- (UIView*)firstResponderInView:(UIView*)view {
    if ([view isFirstResponder]) {
        return view;
    }
    
    for (UIView *subview in view.subviews) {
        UIView *fr = [self firstResponderInView:subview];
        if (fr) {
            return fr;
        }
    }
    
    return nil;
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSValue *keyboard = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[keyboard CGRectValue]
                                        fromView:nil];
    CGSize keyboardSize = keyboardRect.size;

    NSValue *durationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [durationValue getValue:&duration];

    NSValue *curveValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions options = 0;
    [curveValue getValue:&options];
    options |= UIViewAnimationOptionBeginFromCurrentState;
    options |= UIViewAnimationOptionAllowAnimatedContent;

    UIView *responder = [self firstResponderInView:self.view];
    CGRect responderRect = CGRectZero;
    if (responder) {
        responderRect = responder.frame;
        CGFloat minFrame = responderRect.origin.y + responderRect.size.height;
        if (minFrame > keyboardSize.height) {
    	    responderRect.origin.y += 10;
        }
    }

	CGRect viewFrame = self.scrollView.frame;
	viewFrame.size.height -= keyboardSize.height;

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^ {
                         [self.scrollView setFrame:viewFrame];
                         [self.scrollView scrollRectToVisible:responderRect
                                                     animated:NO];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSValue *keyboardValue = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [keyboardValue CGRectValue];

    NSValue *durationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [durationValue getValue:&duration];

    NSValue *curveValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions options = 0;
    [curveValue getValue:&options];
    options |= UIViewAnimationOptionBeginFromCurrentState;
    
    CGRect visibleRect = self.scrollView.frame;
    visibleRect.size.height += keyboardRect.size.height;

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^ {
                         [self.scrollView setFrame:visibleRect];
                     }
                     completion:^ (BOOL finished) {
                         if (finished) {
                             [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1)
                                                         animated:YES];
                         }
                     }];
}

- (void)keyboardDidHide:(NSNotification*)notification {
}
@end
