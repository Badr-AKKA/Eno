package fr.insee.eno.generation;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.insee.eno.transform.xsl.XslParameters;
import fr.insee.eno.transform.xsl.XslTransformation;
import fr.insee.eno.Constants;

public class DDI2ODTGenerator implements Generator {
	
	private static final Logger logger = LogManager.getLogger(DDI2ODTGenerator.class);
	
	// FIXME Inject !
	private static XslTransformation saxonService = new XslTransformation();

	@Override
	public File generate(File finalInput, String surveyName) throws Exception {
		logger.info("DDI2ODT Target : START");
		logger.debug("Arguments : finalInput : " + finalInput + " surveyName " + surveyName);
		String formNameFolder = null;
		String outputBasicFormPath = null;

		formNameFolder = getFormNameFolder(finalInput);

		logger.debug("formNameFolder : " + formNameFolder);

		outputBasicFormPath = Constants.TEMP_ODT_FOLDER + "/" + formNameFolder + "/" + Constants.BASIC_FORM_TMP_FILENAME;
		logger.debug("Output folder for basic-form : " + outputBasicFormPath);
		
		
		InputStream isTRANSFORMATIONS_DDI2ODT_DDI2ODT_XSL = Constants.getInputStreamFromPath(Constants.TRANSFORMATIONS_DDI2ODT_DDI2ODT_XSL);
		InputStream isPROPERTIES_FILE = Constants.getInputStreamFromPath(Constants.PROPERTIES_FILE_ODT);
		InputStream isPARAMETERS_FILE = Constants.getInputStreamFromPath(Constants.PARAMETERS_FILE);
		
		saxonService.transformDDI2ODT(
				FileUtils.openInputStream(finalInput),
				FileUtils.openOutputStream(new File(outputBasicFormPath)),
				isTRANSFORMATIONS_DDI2ODT_DDI2ODT_XSL,
				isPROPERTIES_FILE,
				isPARAMETERS_FILE);
		
		isTRANSFORMATIONS_DDI2ODT_DDI2ODT_XSL.close();
		isPROPERTIES_FILE.close();
		isPARAMETERS_FILE.close();
		
		String outputForm = Constants.TEMP_FOLDER_PATH + "/" + surveyName + "/" + formNameFolder + "/form/form.odt";
		
		InputStream isOutputBasicFormPath = FileUtils.openInputStream(new File(outputBasicFormPath));
		OutputStream osOutputForm = FileUtils.openOutputStream(new File(outputForm));
		InputStream isBROWSING_TEMPLATE_XSL = Constants.getInputStreamFromPath(Constants.BROWSING_ODT_TEMPLATE_XSL);
		saxonService.transformBrowsingDDI2ODT(
				isOutputBasicFormPath,
				osOutputForm,
				isBROWSING_TEMPLATE_XSL,
				Constants.LABEL_FOLDER);
		isOutputBasicFormPath.close();
		osOutputForm.close();
		isBROWSING_TEMPLATE_XSL.close();
		
		
		return new File(outputForm);
	}

	/**
	 * @param finalInput
	 * @return
	 */
	private String getFormNameFolder(File finalInput) {
		String formNameFolder;
		formNameFolder = FilenameUtils.getBaseName(finalInput.getAbsolutePath());
		formNameFolder = FilenameUtils.removeExtension(formNameFolder);
		formNameFolder = formNameFolder.replace(XslParameters.TITLED_EXTENSION, "");
		return formNameFolder;
	}

}
