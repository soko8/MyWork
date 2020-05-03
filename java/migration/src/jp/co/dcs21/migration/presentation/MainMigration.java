package jp.co.dcs21.migration.presentation;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.sql.SQLException;

import javax.swing.ComboBoxModel;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import javax.swing.filechooser.FileNameExtensionFilter;

import jp.co.dcs21.migration.logic.AddressBusinessLogicImpl;
import jp.co.dcs21.migration.logic.BusinessLogic;
import jp.co.dcs21.migration.logic.MigrationBusinessLogicImpl;
import jp.co.dcs21.migration.persistence.DbUtils;
import jp.co.dcs21.migration.persistence.MasterInfo;
import jp.co.dcs21.migration.utils.CsvHandler;
import jp.co.dcs21.migration.utils.FileHandler;
import jp.co.dcs21.migration.utils.XlsHandler;
import jp.co.dcs21.migration.utils.XlsxHandler;

import org.xml.sax.SAXException;


/**
 *
 *
*/
public class MainMigration extends javax.swing.JFrame {

	/**    */
	private static final long serialVersionUID = 1L;

	private JLabel fileLable;
	private JComboBox fileComboBox;
	private JButton okBtn;
	private JButton pathSelBtn;
	private JButton fileSelBtn;
	private JComboBox outputPathComboBox;
	private JButton cancleBtn;
	private JLabel outputPathLable;

	/**
	* Auto-generated main method to display this JFrame
	*/
	public static void main(String[] args) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				MainMigration inst = new MainMigration();
				inst.setLocationRelativeTo(null);
				inst.setVisible(true);
			}
		});
	}

	public MainMigration() {
		super();
		initGUI();
	}

	private void initGUI() {
		try {
			{
				GridBagLayout thisLayout = new GridBagLayout();
				thisLayout.rowWeights = new double[] {0.1, 0.0, 0.0, 0.0, 0.1};
				thisLayout.rowHeights = new int[] {20, 35, 35, 55, 7};
				thisLayout.columnWeights = new double[] {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
				thisLayout.columnWidths = new int[] {75, 500, 45, 10, 40, 45};
				getContentPane().setLayout(thisLayout);
				this.setTitle("移行ツール");
				{
					fileLable = new JLabel();
					getContentPane().add(fileLable, new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.WEST, GridBagConstraints.VERTICAL, new Insets(2, 1, 2, 1), 0, 0));
					fileLable.setText("ファイル   ：");
					fileLable.setFont(new java.awt.Font("MS UI Gothic",1,14));
				}
				{
					ComboBoxModel fileComboBoxModel =
							new DefaultComboBoxModel(
									new String[] {});
					fileComboBox = new JComboBox();
					getContentPane().add(fileComboBox, new GridBagConstraints(1, 1, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(2, 1, 2, 1), 0, 0));
					fileComboBox.setModel(fileComboBoxModel);
					fileComboBox.setEditable(true);
					fileComboBox.setSize(637, 32);
				}
				{
					outputPathLable = new JLabel();
					getContentPane().add(outputPathLable, new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.WEST, GridBagConstraints.NONE, new Insets(2, 1, 2, 1), 0, 0));
					outputPathLable.setText("出力パス ：");
					outputPathLable.setFont(new java.awt.Font("MS UI Gothic",1,14));
				}
				{
					okBtn = new JButton();
					getContentPane().add(okBtn, new GridBagConstraints(2, 3, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(10, 0, 0, 0), 0, 0));
					okBtn.setText("開始");
					okBtn.setFont(new java.awt.Font("MS UI Gothic",1,14));
					okBtn.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent evt) {
							String file = (String) fileComboBox.getSelectedItem();
							String path = (String) outputPathComboBox.getSelectedItem();

							int option = JOptionPane.showConfirmDialog(null, "実績データの取り込みを行いますか", "取込確認", JOptionPane.YES_NO_OPTION);

							if (JOptionPane.NO_OPTION == option) {
								return;
							}

							int result = process(file, path);

							// ファイルが存在していない
							if (1 == result) {

							} else if (2 == result) {	// ファイルが読み込めない

							} else if (3 == result) {	//

							} else if (4 == result) {	//

							} else if (5 == result) {	//

							} else if (6 == result) {	//

							} else {					//　正常終了
								JOptionPane.showMessageDialog(null, "移行処理が正常に終了しました。", "移行正常終了", JOptionPane.INFORMATION_MESSAGE);
							}

							//TODO add your code for okBtn.actionPerformed
						}
					});
				}
				{
					cancleBtn = new JButton();
					getContentPane().add(cancleBtn, new GridBagConstraints(5, 3, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(10, 0, 0, 0), 0, 0));
					cancleBtn.setText("取消");
					cancleBtn.setFont(new java.awt.Font("MS UI Gothic",1,14));
					cancleBtn.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent evt) {

							System.exit(DISPOSE_ON_CLOSE);

						}
					});
				}
				{
					ComboBoxModel outputPathComboBoxModel =
							new DefaultComboBoxModel(
									new String[] {});
					outputPathComboBox = new JComboBox();
					getContentPane().add(outputPathComboBox, new GridBagConstraints(1, 2, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(2, 1, 2, 1), 0, 0));
					outputPathComboBox.setModel(outputPathComboBoxModel);
					outputPathComboBox.setEditable(true);
					outputPathComboBox.setSize(637, 32);
				}
				{
					fileSelBtn = new JButton();
					getContentPane().add(fileSelBtn, new GridBagConstraints(4, 1, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(2, 1, 2, 1), 0, 0));
					fileSelBtn.setText("選択");
					fileSelBtn.setFont(new java.awt.Font("MS UI Gothic",0,12));
					fileSelBtn.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent evt) {
							JFileChooser fc = new JFileChooser(".");
							fc.setDialogTitle("読み込みファイル選択");
							fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
							fc.setFileFilter(new FileNameExtensionFilter("xls & xlsx &csv", "xls", "xlsx", "csv"));
							if (JFileChooser.APPROVE_OPTION == fc.showOpenDialog(null)) {
								String fileName = fc.getSelectedFile().getAbsolutePath();
								fileComboBox.addItem(fileName);
								fileComboBox.setSelectedItem(fileName);
							}
						}
					});
				}
				{
					pathSelBtn = new JButton();
					getContentPane().add(pathSelBtn, new GridBagConstraints(4, 2, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(2, 1, 2, 1), 0, 0));
					pathSelBtn.setText("選択");
					pathSelBtn.setFont(new java.awt.Font("MS UI Gothic",0,12));
					pathSelBtn.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent evt) {
							JFileChooser fc = new JFileChooser(".");
							fc.setDialogTitle("出力パス選択");
							fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
							if (JFileChooser.APPROVE_OPTION == fc.showOpenDialog(null)) {
								String fileName = fc.getSelectedFile().getAbsolutePath();
								outputPathComboBox.addItem(fileName);
								outputPathComboBox.setSelectedItem(fileName);
							}
						}
					});
				}
			}
			this.setSize(821, 250);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private int process(String file, String outputPath) {
		System.err.println(file);


		try {

			BusinessLogic bl = new MigrationBusinessLogicImpl();
			((MigrationBusinessLogicImpl) bl).setTablesMeta(DbUtils.getInstacne().getTablesMeta());

			MasterInfo.init();

			AddressBusinessLogicImpl address = new AddressBusinessLogicImpl();
			CsvHandler addressFh = new CsvHandler("c:/temp/KEN_ALL.CSV", address);
			addressFh.setCharsetName("SJIS");
			addressFh.read();

			address.setRoma(true);
			((CsvHandler) addressFh).setFile("c:/temp/KEN_ALL_ROME.CSV");
			addressFh.read();

			((MigrationBusinessLogicImpl) bl).setIndexDictionary(address.getIndexDictionary());
			((MigrationBusinessLogicImpl) bl).setRomaji(address.getRomaji());


			FileHandler fh = null;

			if (file.endsWith(".xls")) {
				fh = new XlsHandler(file, bl);
			} else if (file.endsWith(".xlsx")) {
				fh = new XlsxHandler(file, bl);
			} else if (file.endsWith(".csv")) {
				fh = new CsvHandler(file, bl);
			} else {
				// TODO error msg
			}

//			MasterInfo.init();

			fh.read();



		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {

			try {
				DbUtils.getInstacne().getConnection().commit();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SAXException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			DbUtils.getInstacne().closeConnection();
		}

		return 0;
	}

}
